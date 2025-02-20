from flask import Flask, request, send_file
import cv2
import numpy as np
import io
from PIL import Image

app = Flask(__name__)

@app.route('/process', methods=['POST'])
def process_image():
    # Bild vom Request auslesen
    file = request.files['image']
    in_memory_file = io.BytesIO(file.read())
    img = np.array(Image.open(in_memory_file))
    
    # Falls nötig, konvertiere das Bild in BGR (OpenCV arbeitet meist mit BGR)
    if img.shape[2] == 3:
        img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
    
    # Beispiel-Verarbeitung: Umwandeln in Graustufen und Kanten erkennen
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 150)
    
    # Bild in JPEG umkodieren, um es zurückzusenden
    _, buffer = cv2.imencode('.jpg', edges)
    return send_file(io.BytesIO(buffer.tobytes()), mimetype='image/jpeg')

if __name__ == '__main__':
    # Starte den Server; für Tests lokal: http://localhost:5000
    app.run(host='0.0.0.0', port=5000, debug=True)
