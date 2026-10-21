import subprocess

try:
    while True:
        subprocess.run(["python3", "forward.py"])
        subprocess.run(["python3", "backward.py"])

except KeyboardInterrupt:
    print("Stopped random movement.")
