import sys
import whisper

def transcribe_audio(file_path):
    model = whisper.load_model("tiny")  # ✅ Smallest model
    result = model.transcribe(file_path)
    print(result["text"])  # Outputs transcription

if __name__ == "__main__":
    audio_file = sys.argv[1]
    transcribe_audio(audio_file)
