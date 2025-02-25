
# Choose Python 3.11 (py11) as conda environment
import torch
import whisper
import time
 
# Chemin du fichier audio à transcrire
entretien  = "C:/Users/mathieu.yeche/Desktop/audio.aac" 
entretien  = "C:/Users/mathieu.yeche/Downloads/Temp(a suppr)/r/20240530_114727.m4a" 
entretien  = "C:/Users/mathieu.yeche/Desktop/tel/asuppr.m4a"
outputName = "PrepaISEK"


#entretien = "C:/Users/mathieu.yeche/Downloads/Preparation ISPGR.wav" 
# Taille du modèle de transcription
modele_whisper = "large-v3" 
Langue = "fr"

print("Chargement du modèle")
model = whisper.load_model(modele_whisper, device="cuda")


# Une fonction pour faciliter l'horodatage des segments de parole en heures, minutes et secondes
def convertir(seconds):
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = int(seconds % 60)
    return f"{h:02d}:{m:02d}:{s:02d}"
 
# Chemin où vous souhaitez enregistrer votre transcription d'entretien en format .txt

def Transcrire(Langue):
    print("Transcription en " + Langue + " commencée")
    if Langue == "all" | Langue == "":
        transcription = model.transcribe(entretien)
    else:
        transcription = model.transcribe(entretien, language=Langue)
    print("Transcription en " + Langue + " terminée")
    
    # Enregistrement de la transcription
    if Langue == "all":
        Langue = ""
    else:
        Langue = "_" + Langue
    entretien_transcrit = "C:/Users/mathieu.yeche/Desktop/IA_Output/Audio/script_" + outputName + Langue + "-" + time.strftime('%Y%m%d_%H%M%S') + ".txt"
    with open(entretien_transcrit , 'w', encoding='utf-8') as f:
        for segment in transcription["segments"]:
            start_time = convertir(segment['start'])
            end_time = convertir(segment['end'])
            f.write(f"{start_time} - {end_time}: {segment['text']}\n")
        new_line = "\n"
        f.write(f"{new_line}\n")
        for segment in transcription["segments"]:
            start_time = convertir(segment['start'])
            end_time = convertir(segment['end'])
            f.write(f"{segment['text']}\n")
     
Transcrire("all") # fr / en / all

            
