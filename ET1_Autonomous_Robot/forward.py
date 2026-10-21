from helper import *

try:
    left_pwm, right_pwm = setup()

    global left_count, right_count
    left_count = 0
    right_count = 0

    move_forward(left_pwm, right_pwm)

    while True:
        dist = get_distance()
        print(f"Distance to obstacle: {dist} cm")

        if dist < OBSTACLE_THRESHOLD_CM:
            stop_motors(left_pwm, right_pwm)
            break

        time.sleep(0.1)

    print(f"Stopped at {dist} cm")
    print(
        f"Left wheel pulses: {left_count}, "
        f"Right wheel pulses: {right_count}"
    )

finally:
    left_pwm.stop()
    right_pwm.stop()
    GPIO.cleanup()
