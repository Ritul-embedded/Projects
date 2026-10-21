import time

import RPi.GPIO as GPIO


# GPIO pins
BUTTON_PIN = 5

# Left motor
LEFT_PWM = 18
LEFT_IN1 = 17
LEFT_IN2 = 22

# Right motor
RIGHT_PWM = 19
RIGHT_IN1 = 24
RIGHT_IN2 = 4


def setup_gpio():
    """Configure the button, motor direction pins, and PWM outputs."""
    GPIO.setwarnings(False)
    GPIO.setmode(GPIO.BCM)

    GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

    motor_direction_pins = [
        LEFT_IN1,
        LEFT_IN2,
        RIGHT_IN1,
        RIGHT_IN2,
    ]

    for pin in motor_direction_pins:
        GPIO.setup(pin, GPIO.OUT)
        GPIO.output(pin, GPIO.LOW)

    GPIO.setup(LEFT_PWM, GPIO.OUT)
    GPIO.setup(RIGHT_PWM, GPIO.OUT)

    left_pwm = GPIO.PWM(LEFT_PWM, 1000)
    right_pwm = GPIO.PWM(RIGHT_PWM, 1000)

    left_pwm.start(0)
    right_pwm.start(0)

    return left_pwm, right_pwm


def move(left_pwm, right_pwm, forward=True):
    """Accelerate and decelerate the robot in the selected direction."""
    GPIO.output(LEFT_IN1, GPIO.HIGH if forward else GPIO.LOW)
    GPIO.output(LEFT_IN2, GPIO.LOW if forward else GPIO.HIGH)
    GPIO.output(RIGHT_IN1, GPIO.HIGH if forward else GPIO.LOW)
    GPIO.output(RIGHT_IN2, GPIO.LOW if forward else GPIO.HIGH)

    direction = "forward" if forward else "backward"
    print(f"Accelerating {direction}")

    for speed in range(0, 101, 5):
        left_pwm.ChangeDutyCycle(speed)
        right_pwm.ChangeDutyCycle(speed)
        time.sleep(0.1)

    print(f"Decelerating {direction}")

    for speed in range(100, -1, -5):
        left_pwm.ChangeDutyCycle(speed)
        right_pwm.ChangeDutyCycle(speed)
        time.sleep(0.1)


def main():
    left_pwm, right_pwm = setup_gpio()

    try:
        print("Press the button to start forward-backward motion.")

        while True:
            if GPIO.input(BUTTON_PIN) == GPIO.LOW:
                move(left_pwm, right_pwm, forward=True)
                time.sleep(1)
                move(left_pwm, right_pwm, forward=False)
                print("Motion complete.")
                break

            time.sleep(0.05)

    except KeyboardInterrupt:
        print("Interrupted by user.")

    finally:
        left_pwm.stop()
        right_pwm.stop()
        GPIO.cleanup()


if __name__ == "__main__":
    main()
