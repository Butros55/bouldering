from flask import Flask, request, send_file
from flask_cors import CORS
import cv2
import numpy as np
import io
from PIL import Image

app = Flask(__name__)
CORS(app)  # Erlaubt Cross-Origin-Anfragen, wichtig für Flutter Web

# HSV-Farbbereiche für die Boulderfarben
# Diese Werte sind NUR ein Startpunkt und müssen je nach Beleuchtung & Griff-Farbton angepasst werden!
COLOR_RANGES = {
    # Gelb
    "gelb":   [(20,  100, 100), (30, 255, 255)],
    # Türkis
    "tuerkis":[(80,  100, 100), (95, 255, 255)],
    # Lila (Violett)
    "lila":   [(140, 100, 100), (160, 255, 255)],
    # Weiß (sehr schwierig in HSV, da S und V hoch sind, muss man experimentieren)
    "weiss":  [(0,   0,   200), (180, 50,  255)],
    # Rot: zwei Bereiche (wegen Hue-Übergang bei 180)
    "rot1":   [(0,   120, 70),  (10, 255, 255)],
    "rot2":   [(170, 120, 70),  (180, 255, 255)],
    # Blau
    "blau":   [(100, 100, 70),  (130, 255, 255)],
    # Orange
    "orange": [(10,  100, 100), (20, 255, 255)],
    # Optional: Schwarz => hier ignorieren wir es
    # Schwarz hätte evtl. (H: 0..180, S: 0..50, V: 0..50), aber wir fügen es NICHT zum output hinzu.
}

@app.route('/process', methods=['POST'])
def process_image():
    file = request.files['image']
    in_memory_file = io.BytesIO(file.read())
    img = np.array(Image.open(in_memory_file))

    # Bei Bedarf von RGB zu BGR konvertieren (wenn PIL in RGB liest)
    if img.shape[2] == 3:
        img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

    # In HSV umwandeln
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # Output-Bild: Anfangs komplett schwarz, gleiche Größe wie Original
    output = np.zeros_like(img)

    for color_name, (lower_vals, upper_vals) in COLOR_RANGES.items():
        lower = np.array(lower_vals, dtype=np.uint8)
        upper = np.array(upper_vals, dtype=np.uint8)

        mask = cv2.inRange(hsv, lower, upper)

        # Für Rot kombinieren wir rot1 und rot2
        # => Man kann es im Dictionary splitten (wie oben),
        #    oder hier direkt zusammenfassen, falls man mag.
        if color_name == "rot1":
            # rot2 dazuholen
            lower_rot2 = np.array(COLOR_RANGES["rot2"][0], dtype=np.uint8)
            upper_rot2 = np.array(COLOR_RANGES["rot2"][1], dtype=np.uint8)
            mask2 = cv2.inRange(hsv, lower_rot2, upper_rot2)
            mask = mask | mask2

        # Bitwise-AND, um nur die gefilterte Farbe aus dem Originalbild zu übernehmen
        color_segment = cv2.bitwise_and(img, img, mask=mask)

        # Im output-Bild hinzufügen (Pixelweise addieren)
        output = cv2.add(output, color_segment)

    # Ausgabe als JPEG
    _, buffer = cv2.imencode('.jpg', output)
    return send_file(io.BytesIO(buffer.tobytes()), mimetype='image/jpeg')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
