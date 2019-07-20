defmodule FrankenfunctorTest do
  use ExUnit.Case

  alias Frankenfunctor.{DeadLeftBrokenArm, DeadLeftLeg, LiveLeftArm, LiveLeftLeg, M, VitalForce}

  import Frankenfunctor

  test "getting vital force" do
    vital_force = VitalForce.new(10)

    {actual_vital_force, remaining_vital_force} = VitalForce.get_vital_force(vital_force)

    assert actual_vital_force == VitalForce.new(1)
    assert remaining_vital_force == VitalForce.new(9)
  end

  test "left leg" do
    dead_left_leg = DeadLeftLeg.new("Boris")
    left_leg_m = make_live_left_leg_m(dead_left_leg)
    vf = VitalForce.new(10)
    {:m, inner_fn} = left_leg_m

    {live_left_leg, remaining_after_left_leg} = inner_fn.(vf)

    assert live_left_leg == LiveLeftLeg.new("Boris", VitalForce.new(1))
    assert remaining_after_left_leg == VitalForce.new(9)
  end

  test "testing left arm" do
    dead_left_broken_arm = DeadLeftBrokenArm.new("Victor")
    left_broken_arm_m = make_live_left_broken_arm(dead_left_broken_arm)
    left_arm_m = map_m(left_broken_arm_m, &heal_broken_arm/1)
    vf = VitalForce.new(10)

    {live_left_arm, remaining_after_left_arm} = M.run_m(left_arm_m, vf)

    assert live_left_arm == LiveLeftArm.new("Victor", VitalForce.new(1))
    assert remaining_after_left_arm == VitalForce.new(9)
  end
end
