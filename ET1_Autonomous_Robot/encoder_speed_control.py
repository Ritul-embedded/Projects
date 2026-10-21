import time
import RPi.GPIO as GPIO

# -----------------------------
# Motor Pins
# -----------------------------
LEFT_PWM = 18
LEFT_IN1 = 17
LEFT_IN2 = 22

RIGHT_PWM = 19
RIGHT_IN1 = 24
RIGHT_IN2 = 4

# -----------------------------
# Encoder Pins
# -----------------------------
LEFT_ENCODER = 23
RIGHT_ENCODER = 27

# -----------------------------
# Encoder Counters
# -----------------------------
left_count = 0
right_count = 0

BASE_SPEED = 60
MAX_ADJUST = 10


def left_encoder_callback(channel):
    global left_count
    left_count += 1


def right_encoder_callback(channel):
    global right_count
    right_count += 1


GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)

for pin in [
    LEFT_IN1,
    LEFT_IN2,
    RIGHT_IN1,
    RIGHT_IN2,
    LEFT_PWM,
    RIGHT_PWM,
]:
    GPIO.setup(pin, GPIO.OUT)

GPIO.setup(LEFT_ENCODER, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(RIGHT_ENCODER, GPIO.IN, pull_up_down=GPIO.PUD_UP)

GPIO.add_event_detect(
    LEFT_ENCODER,
    GPIO.RISING,
    callback=left_encoder_callback
)

GPIO.add_event_detect(
    RIGHT_ENCODER,
    GPIO.RISING,
    callback=right_encoder_callback
)

left_pwm = GPIO.PWM(LEFT_PWM, 1000)
right_pwm = GPIO.PWM(RIGHT_PWM, 1000)

left_pwm.start(0)
right_pwm.start(0)


def set_forward_direction():
    GPIO.output(LEFT_IN1, GPIO.HIGH)
    GPIO.output(LEFT_IN2, GPIO.LOW)
    GPIO.output(RIGHT_IN1, GPIO.HIGH)
    GPIO.output(RIGHT_IN2, GPIO.LOW)


def stop_motors():
    left_pwm.ChangeDutyCycle(0)
    right_pwm.ChangeDutyCycle(0)

    GPIO.output(LEFT_IN1, GPIO.LOW)
    GPIO.output(LEFT_IN2, GPIO.LOW)
    GPIO.output(RIGHT_IN1, GPIO.LOW)
    GPIO.output(RIGHT_IN2, GPIO.LOW)


try:

    print("Running encoder-based speed correction...")

    left_count = 0
    right_count = 0

    set_forward_direction()

    left_pwm.ChangeDutyCycle(BASE_SPEED)
    right_pwm.ChangeDutyCycle(BASE_SPEED)

    start_time = time.time()

    duration = 10

    while time.time() - start_time < duration:

        error = left_count - right_count

        adjust = int(0.5 * error)

        adjust = max(-MAX_ADJUST, min(MAX_ADJUST, adjust))

        left_speed = max(0, min(100, BASE_SPEED - adjust))
        right_speed = max(0, min(100, BASE_SPEED + adjust))

        left_pwm.ChangeDutyCycle(left_speed)
        right_pwm.ChangeDutyCycle(right_speed)

        print(
            f"L:{left_count}  "
            f"R:{right_count}  "
            f"Adjust:{adjust}"
        )

        time.sleep(0.1)

    print("Finished.")

except KeyboardInterrupt:
    print("Interrupted.")

finally:
    stop_motors()

    left_pwm.stop()
    right_pwm.stop()

    GPIO.cleanup()
