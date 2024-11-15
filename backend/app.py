# -*- coding: utf-8 -*-
import os
import numpy as np
import tensorflow as tf
from keras.models import load_model
from ultralytics import YOLO
import cv2
from flask import Flask, request, jsonify, send_file
from PIL import Image
import io

app = Flask(__name__)

# Carregar modelos
path_model_localize = "C:/Coffe-App-PAVIC/backend/teste2/best.pt"  # Atualize com o caminho do seu modelo YOLO
model_localize = YOLO(path_model_localize)

path_classifier = "C:/Coffe-App-PAVIC/backend/teste2/model_PavicNet_BRACOL_V7.hdf5"  # Atualize com o caminho do seu classificador
model_all_0 = load_model(path_classifier)

@app.route('/diagnose', methods=['POST'])
def diagnose():
    # Verifica se a requisição contém um arquivo
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400
    
    # Carrega a imagem recebida
    image_file = request.files['image']
    image = Image.open(image_file)
    image = np.array(image)

    # Converte a imagem de RGB para BGR
    image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

    # Realizar a detecção de objetos na imagem
    results = model_localize(image)
    boxes = results[0].boxes.xyxy

    # Processamento das caixas delimitadoras e previsões
    diagnosis = []
    for i in range(len(boxes)):
        box = boxes[i]
        x, y, w, h = map(int, box[:4])
        cropped = image[y:h, x:w]

        # Prepara a imagem para o classificador
        img_cortada = cv2.resize(cropped, (224, 224))
        img_cortada = img_cortada / 255.0
        img_cortada = tf.expand_dims(img_cortada, axis=0)

        # Previsão do modelo
        pred = model_all_0.predict(img_cortada, verbose=None)
        confidence = pred.max()
        pred2 = np.array(pred[0] > 0.8)

        # Armazena o diagnóstico de cada região e desenha na imagem
        label = ""
        color = (255, 255, 255)  # Cor padrão, branco
        if pred2[0]:
            label = "Rust"
            color = (0, 0, 255)  # Vermelho
        elif pred2[1]:
            label = "Miner"
            color = (0, 255, 0)  # Verde
        elif pred2[2]:
            label = "Phoma"
            color = (255, 0, 0)  # Azul
        elif pred2[3]:
            label = "Cercospora"
            color = (0, 255, 255)  # Amarelo
        
        # Adicionar o diagnóstico à lista
        diagnosis.append(label)
        
        # Desenhar a caixa e o diagnóstico na imagem com a cor correspondente
        cv2.rectangle(image, (x, y), (w, h), color, 2)
        cv2.putText(image, label, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

    # Convertendo a imagem processada para um formato de resposta
    _, buffer = cv2.imencode('.jpg', image)
    io_buf = io.BytesIO(buffer)

    # Envia a imagem processada como uma resposta binária
    return send_file(io_buf, mimetype='image/jpeg')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
