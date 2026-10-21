import random
import time

import RPi.GPIO as GPIO


# ============================================================
# Motor pins
# ============================================================

LEFT_PWM = 18
LEFT_IN1 = 17
LEFT_IN2 = 22

RIGHT_PWM = 19
RIGHT_IN1 = 24
RIGHT_IN2 = 4


# ============================================================
# Encoder pins
# ============================================================

LEFT_ENCODER = 23
RIGHT_ENCODER = 16


# ============================================================
# HC-SR04 ultrasonic sensor pins
# ============================================================

TRIG = 25
ECHO = 27


# ============================================================
# Control constants
# ============================================================

PULSES_PER_REV = 20

# Adjust experimentally until the robot turns approximately 90 degrees.
PULSES_FOR_90_DEG = 20

OBSTACLE_THRESHOLD_CM = 20
BASE_SPEED = 60

# Maximum time to wait for the ultrasonic echo signal.
SENSOR_TIMEOUT_SECONDS = 0.1


# ============================================================
# Global encoder counters
# ============================================================

left_count = 0
right_count = 0


# ============================================================
# Encoder callbacks
# ============================================================

def left_encoder_callback(channel):
    """Increment the left encoder pulse count."""
    global left_count
    left_count += 1


def right_encoder_callback(channel):
    """Increment the right encoder pulse count."""
    global right_count
    right_count += 1


# ============================================================
# GPIO setup
# ============================================================

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)

motor_output_pins = [
    LEFT_IN1,
    LEFT_IN2,
    RIGHT_IN1,
    RIGHT_IN2,
    LEFT_PWM,
    RIGHT_PWM,
]

for pin in motor_output_pins:
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


# ============================================================
# PWM setup
# ============================================================

left_pwm = GPIO.PWM(LEFT_PWM, 1000)
right_pwm = GPIO.PWM(RIGHT_PWM, 1000)

left_pwm.start(0)
right_pwm.start(0)


# ============================================================
# Motion-control functions
# ============================================================

def set_forward():
    """Configure both motors to move the robot forward."""
    GPIO.output(LEFT_IN1, GPIO.HIGH)
    GPIO.output(LEFT_IN2, GPIO.LOW)

    GPIO.output(RIGHT_IN1, GPIO.HIGH)
    GPIO.output(RIGHT_IN2, GPIO.LOW)


def stop_motors():
    """Stop both motors and place direction pins in a safe state."""
    left_pwm.ChangeDutyCycle(0)
    right_pwm.ChangeDutyCycle(0)

    GPIO.output(LEFT_IN1, GPIO.LOW)
    GPIO.output(LEFT_IN2, GPIO.LOW)

    GPIO.output(RIGHT_IN1, GPIO.LOW)
    GPIO.output(RIGHT_IN2, GPIO.LOW)

    print("Motors stopped.")


def turn_90(direction="left"):
    """
    Rotate the robot approximately 90 degrees.

    The turn stops when either encoder reaches the calibrated pulse count.
    """
    global left_count, right_count

    if direction not in ("left", "right"):
        raise ValueError("Direction must be 'left' or 'right'.")

    left_count = 0
    right_count = 0

    if direction == "left":
        # Left motor backward
        GPIO.output(LEFT_IN1, GPIO.LOW)
        GPIO.output(LEFT_IN2, GPIO.HIGH)

        # Right motor forward
        GPIO.output(RIGHT_IN1, GPIO.HIGH)
        GPIO.output(RIGHT_IN2, GPIO.LOW)

    else:
        # Left motor forward
        GPIO.output(LEFT_IN1, GPIO.HIGH)
        GPIO.output(LEFT_IN2, GPIO.LOW)

        # Right motor backward
        GPIO.output(RIGHT_IN1, GPIO.LOW)
        GPIO.output(RIGHT_IN2, GPIO.HIGH)

    left_pwm.ChangeDutyCycle(BASE_SPEED)
    right_pwm.ChangeDutyCycle(BASE_SPEED)

    print(
        f"Turning {direction}. "
        f"Waiting for {PULSES_FOR_90_DEG} encoder pulses."
    )

    while max(left_count, right_count) < PULSES_FOR_90_DEG:
        print(
            f"Encoder counts: "
            f"L={left_count}, R={right_count}"
        )
        time.sleep(0.01)

    stop_motors()
    print("Turn complete.")
    time.sleep(0.5)


# ============================================================
# Ultrasonic distance measurement
# ============================================================

def get_distance():
    """
    Measure distance using the HC-SR04 ultrasonic sensor.

    Returns:
        float: Distance in centimetres.

        A value of 999 is returned when no valid echo is received
        before the timeout.
    """
    GPIO.output(TRIG, GPIO.LOW)
    time.sleep(0.01)

    # Send a 10-microsecond trigger pulse.
    GPIO.output(TRIG, GPIO.HIGH)
    time.sleep(0.00001)
    GPIO.output(TRIG, GPIO.LOW)

    wait_start = time.monotonic()

    # Wait for the echo pulse to begin.
    while GPIO.input(ECHO) == GPIO.LOW:
        if time.monotonic() - wait_start >= SENSOR_TIMEOUT_SECONDS:
            print("Sensor timeout: echo pulse did not start.")
            return 999.0

    pulse_start = time.monotonic()

    # Wait for the echo pulse to finish.
    while GPIO.input(ECHO) == GPIO.HIGH:
        if time.monotonic() - pulse_start >= SENSOR_TIMEOUT_SECONDS:
            print("Sensor timeout: echo pulse did not finish.")
            return 999.0

    pulse_end = time.monotonic()

    pulse_duration = pulse_end - pulse_start

    # Speed-of-sound conversion for the round trip:
    # distance in cm = pulse duration × 17150
    distance = pulse_duration * 17150

    return round(distance, 2)


# ============================================================
# Main autonomous-control loop
# ============================================================

def main():
    """Run autonomous forward motion and obstacle avoidance."""
    print("Robot starting...")

    while True:
        set_forward()

        left_pwm.ChangeDutyCycle(BASE_SPEED)
        right_pwm.ChangeDutyCycle(BASE_SPEED)

        # Continue moving forward while the route is clear.
        while True:
            distance = get_distance()
            print(f"Distance: {distance} cm")

            if distance < OBSTACLE_THRESHOLD_CM:
                print("Obstacle detected!")
                stop_motors()
                break

            time.sleep(0.1)

        # Select a new direction after detecting an obstacle.
        direction = random.choice(["left", "right"])
        print(f"Turning {direction}")

        turn_90(direction)


# ============================================================
# Program entry point and cleanup
# ============================================================

if __name__ == "__main__":
    try:
        main()

    except KeyboardInterrupt:
        print("\nInterrupted by user.")

    finally:
        print("Cleaning up GPIO.")

        stop_motors()

        left_pwm.stop()
        right_pwm.stop()

        GPIO.cleanup()
