import base64
from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
import io
from PIL import Image

app = Flask(__name__)
CORS(app)

# HSV-Farbranges für Boulderfarben – passe diese an deine Halle an.
COLOR_RANGES = {
    "gelb":   [(20,  100, 100), (30, 255, 255)],
    "tuerkis":[(80,  100, 100), (95, 255, 255)],
    "lila":   [(140, 100, 100), (160, 255, 255)],
    "rot1":   [(0,   120, 70),  (10, 255, 255)],
    "rot2":   [(170, 120, 70),  (180, 255, 255)],
    "blau":   [(100, 100, 70),  (130, 255, 255)],
    "orange": [(10,  100, 100), (20, 255, 255)],
    "weiss":  [(0,   0,   220), (180, 40,  255)]
    # Schwarz/Volumen ignorieren wir hier.
}

@app.route('/process', methods=['POST'])
def process_image():
    file = request.files['image']
    in_memory_file = io.BytesIO(file.read())
    img = np.array(Image.open(in_memory_file))

    # Konvertiere falls nötig (PIL liest meist in RGB)
    if img.shape[2] == 3:
        img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

    # Encode das Originalbild als base64
    _, orig_buffer = cv2.imencode('.jpg', img)
    orig_base64 = base64.b64encode(orig_buffer).decode('utf-8')

    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    output = np.zeros_like(img)
    all_grips = {}

    for color_name, (lower_vals, upper_vals) in COLOR_RANGES.items():
        if color_name == "rot1":
            lower_rot1 = np.array(COLOR_RANGES["rot1"][0], dtype=np.uint8)
            upper_rot1 = np.array(COLOR_RANGES["rot1"][1], dtype=np.uint8)
            mask1 = cv2.inRange(hsv, lower_rot1, upper_rot1)
            lower_rot2 = np.array(COLOR_RANGES["rot2"][0], dtype=np.uint8)
            upper_rot2 = np.array(COLOR_RANGES["rot2"][1], dtype=np.uint8)
            mask2 = cv2.inRange(hsv, lower_rot2, upper_rot2)
            mask = mask1 | mask2
        elif color_name == "rot2":
            continue
        else:
            lower = np.array(lower_vals, dtype=np.uint8)
            upper = np.array(upper_vals, dtype=np.uint8)
            mask = cv2.inRange(hsv, lower, upper)

        # Morphologische Operationen zur Rauschreduzierung
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
        mask = cv2.erode(mask, kernel, iterations=1)
        mask = cv2.dilate(mask, kernel, iterations=2)

        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        grips_for_color = []
        for cnt in contours:
            area = cv2.contourArea(cnt)
            if area < 50:
                continue
            x, y, w, h = cv2.boundingRect(cnt)
            cx = x + w // 2
            cy = y + h // 2
            grips_for_color.append({
                "x": int(x), "y": int(y),
                "w": int(w), "h": int(h),
                "cx": int(cx), "cy": int(cy)
            })
        if grips_for_color:
            all_grips[color_name] = grips_for_color

        # Zeichne die gefilterte Farbe in das Output-Bild
        color_segment = cv2.bitwise_and(img, img, mask=mask)
        output = cv2.add(output, color_segment)

    # Encode das verarbeitete Bild als base64
    _, buffer = cv2.imencode('.jpg', output)
    proc_base64 = base64.b64encode(buffer).decode('utf-8')

    # Sende beide Bilder und die Griff-Daten zurück
    return jsonify({
        "original_image": orig_base64,
        "processed_image": proc_base64,
        "grip_data": all_grips
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
