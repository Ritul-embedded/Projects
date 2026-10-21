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


def setup():
    GPIO.setwarnings(False)
    GPIO.setmode(GPIO.BCM)

    GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

    for pin in [LEFT_IN1, LEFT_IN2, RIGHT_IN1, RIGHT_IN2]:
        GPIO.setup(pin, GPIO.OUT)
        GPIO.output(pin, GPIO.LOW)

    GPIO.setup(LEFT_PWM, GPIO.OUT)
    GPIO.setup(RIGHT_PWM, GPIO.OUT)

    left_pwm = GPIO.PWM(LEFT_PWM, 1000)
    right_pwm = GPIO.PWM(RIGHT_PWM, 1000)

    left_pwm.start(0)
    right_pwm.start(0)

    return left_pwm, right_pwm


def main():
    left_pwm, right_pwm = setup()

    try:
        print("Waiting for button press to rotate robot...")

        while True:
            if GPIO.input(BUTTON_PIN) == GPIO.LOW:

                print("Rotating using LEFT wheel")

                GPIO.output(LEFT_IN1, GPIO.HIGH)
                GPIO.output(LEFT_IN2, GPIO.LOW)
                left_pwm.ChangeDutyCycle(60)

                time.sleep(10)

                left_pwm.ChangeDutyCycle(0)
                GPIO.output(LEFT_IN1, GPIO.LOW)
                GPIO.output(LEFT_IN2, GPIO.LOW)

                print("Rotating using RIGHT wheel")

                GPIO.output(RIGHT_IN1, GPIO.HIGH)
                GPIO.output(RIGHT_IN2, GPIO.LOW)
                right_pwm.ChangeDutyCycle(60)

                time.sleep(10)

                right_pwm.ChangeDutyCycle(0)
                GPIO.output(RIGHT_IN1, GPIO.LOW)
                GPIO.output(RIGHT_IN2, GPIO.LOW)

                print("Rotation complete")
                break

            time.sleep(0.05)

    except KeyboardInterrupt:
        print("Interrupted by user")

    finally:
        left_pwm.stop()
        right_pwm.stop()
        GPIO.cleanup()


if __name__ == "__main__":
    main()
