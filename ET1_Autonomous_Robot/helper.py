import random
import time

import RPi.GPIO as GPIO


# ============================================================
# GPIO pin assignments
# ============================================================

# Left motor
LEFT_PWM = 18
LEFT_IN1 = 17
LEFT_IN2 = 22

# Right motor
RIGHT_PWM = 19
RIGHT_IN1 = 24
RIGHT_IN2 = 4

# Rotary encoders
LEFT_ENCODER = 23
RIGHT_ENCODER = 16

# HC-SR04 ultrasonic sensor
TRIG = 25
ECHO = 27


# ============================================================
# Control constants
# ============================================================

BASE_SPEED = 60
PULSES_PER_CM = 20       # Calibrate experimentally
TURN_PULSES = 20         # Calibrate for approximately 90 degrees
OBSTACLE_THRESHOLD_CM = 10


# ============================================================
# Global encoder counters
# ============================================================

left_count = 0
right_count = 0


# ============================================================
# Encoder callback functions
# ============================================================

def left_encoder_callback(channel):
    """Increment the left-wheel encoder count."""
    global left_count
    left_count += 1


def right_encoder_callback(channel):
    """Increment the right-wheel encoder count."""
    global right_count
    right_count += 1


# ============================================================
# GPIO and PWM setup
# ============================================================

def setup():
    """Configure GPIO pins, encoder interrupts, and motor PWM."""
    GPIO.setwarnings(False)
    GPIO.setmode(GPIO.BCM)

    motor_pins = [
        LEFT_IN1,
        LEFT_IN2,
        RIGHT_IN1,
        RIGHT_IN2,
        LEFT_PWM,
        RIGHT_PWM,
    ]

    for pin in motor_pins:
        GPIO.setup(pin, GPIO.OUT)
        GPIO.output(pin, GPIO.LOW)

    GPIO.setup(
        LEFT_ENCODER,
        GPIO.IN,
        pull_up_down=GPIO.PUD_UP,
    )

    GPIO.setup(
        RIGHT_ENCODER,
        GPIO.IN,
        pull_up_down=GPIO.PUD_UP,
    )

    GPIO.setup(TRIG, GPIO.OUT)
    GPIO.setup(ECHO, GPIO.IN)
    GPIO.output(TRIG, GPIO.LOW)

    GPIO.add_event_detect(
        LEFT_ENCODER,
        GPIO.RISING,
        callback=left_encoder_callback,
    )

    GPIO.add_event_detect(
        RIGHT_ENCODER,
        GPIO.RISING,
        callback=right_encoder_callback,
    )

    left_pwm = GPIO.PWM(LEFT_PWM, 1000)
    right_pwm = GPIO.PWM(RIGHT_PWM, 1000)

    left_pwm.start(0)
    right_pwm.start(0)

    return left_pwm, right_pwm


# ============================================================
# Motor-control functions
# ============================================================

def stop_motors(left_pwm, right_pwm):
    """Stop both motors."""
    left_pwm.ChangeDutyCycle(0)
    right_pwm.ChangeDutyCycle(0)

    for pin in [LEFT_IN1, LEFT_IN2, RIGHT_IN1, RIGHT_IN2]:
        GPIO.output(pin, GPIO.LOW)


def move_forward(left_pwm, right_pwm):
    """Move both wheels forward."""
    GPIO.output(LEFT_IN1, GPIO.HIGH)
    GPIO.output(LEFT_IN2, GPIO.LOW)

    GPIO.output(RIGHT_IN1, GPIO.HIGH)
    GPIO.output(RIGHT_IN2, GPIO.LOW)

    left_pwm.ChangeDutyCycle(BASE_SPEED)
    right_pwm.ChangeDutyCycle(BASE_SPEED)


def move_backward(left_pwm, right_pwm):
    """Move both wheels backward."""
    GPIO.output(LEFT_IN1, GPIO.LOW)
    GPIO.output(LEFT_IN2, GPIO.HIGH)

    GPIO.output(RIGHT_IN1, GPIO.LOW)
    GPIO.output(RIGHT_IN2, GPIO.HIGH)

    left_pwm.ChangeDutyCycle(BASE_SPEED)
    right_pwm.ChangeDutyCycle(BASE_SPEED)


def turn_random(left_pwm, right_pwm):
    """Select a random direction and perform a timed turn."""
    direction = random.choice(["left", "right"])
    print(f"Turning {direction}")

    if direction == "left":
        # Left wheel backward, right wheel forward
        GPIO.output(LEFT_IN1, GPIO.LOW)
        GPIO.output(LEFT_IN2, GPIO.HIGH)

        GPIO.output(RIGHT_IN1, GPIO.HIGH)
        GPIO.output(RIGHT_IN2, GPIO.LOW)

    else:
        # Left wheel forward, right wheel backward
        GPIO.output(LEFT_IN1, GPIO.HIGH)
        GPIO.output(LEFT_IN2, GPIO.LOW)

        GPIO.output(RIGHT_IN1, GPIO.LOW)
        GPIO.output(RIGHT_IN2, GPIO.HIGH)

    left_pwm.ChangeDutyCycle(BASE_SPEED)
    right_pwm.ChangeDutyCycle(BASE_SPEED)

    time.sleep(0.7)  # Adjust experimentally for the desired turn

    stop_motors(left_pwm, right_pwm)


# ============================================================
# Ultrasonic distance measurement
# ============================================================

def get_distance():
    """
    Measure and return the distance detected by the HC-SR04
    ultrasonic sensor in centimetres.
    """
    GPIO.output(TRIG, GPIO.LOW)
    time.sleep(0.01)

    # Send a 10-microsecond trigger pulse
    GPIO.output(TRIG, GPIO.HIGH)
    time.sleep(0.00001)
    GPIO.output(TRIG, GPIO.LOW)

    timeout_start = time.time()

    # Wait for the echo signal to become HIGH
    while GPIO.input(ECHO) == GPIO.LOW:
        pulse_start = time.time()

        if time.time() - timeout_start >= 0.1:
            print("Ultrasonic sensor timeout.")
            return 999.0

    # Wait for the echo signal to return LOW
    while GPIO.input(ECHO) == GPIO.HIGH:
        pulse_end = time.time()

        if time.time() - timeout_start >= 0.1:
            print("Ultrasonic sensor timeout.")
            return 999.0

    pulse_duration = pulse_end - pulse_start
    distance = pulse_duration * 17150

    return round(distance, 2)
