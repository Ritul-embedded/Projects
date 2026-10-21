import RPi.GPIO as GPIO
import time

# -----------------------------
# GPIO Setup
# -----------------------------
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)

# -----------------------------
# Pin Assignments
# -----------------------------
LED_PIN = 7
BUTTON_PIN = 5

# -----------------------------
# Configure GPIO
# -----------------------------
GPIO.setup(LED_PIN, GPIO.OUT)
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

print("Press the button to turn the LED ON...")

try:
    prev_state = True  # Used to detect button state changes

    while True:
        button_state = GPIO.input(BUTTON_PIN)

        if button_state == GPIO.LOW:
            GPIO.output(LED_PIN, GPIO.HIGH)

            if prev_state:
                print("Button Pressed - LED ON")
                prev_state = False

        else:
            GPIO.output(LED_PIN, GPIO.LOW)

            if not prev_state:
                print("Button Released - LED OFF")
                prev_state = True

        time.sleep(0.05)

except KeyboardInterrupt:
    print("Exiting program.")

finally:
    GPIO.cleanup()
