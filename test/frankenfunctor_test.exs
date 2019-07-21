defmodule FrankenfunctorTest do
  use ExUnit.Case

  alias Frankenfunctor.{
    DeadBrain,
    DeadLeftBrokenArm,
    DeadLeftLeg,
    DeadRightLowerArm,
    DeadRightUpperArm,
    LiveBrain,
    LiveHead,
    LiveLeftArm,
    LiveLeftLeg,
    LiveRightArm,
    LiveRightLowerArm,
    LiveRightUpperArm,
    M,
    Skull,
    VitalForce
  }

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

  test "right arm" do
    dead_right_lower_arm = DeadRightLowerArm.new("Tom")
    lower_right_arm_m = make_live_right_lower_arm(dead_right_lower_arm)
    dead_right_upper_arm = DeadRightUpperArm.new("Jerry")
    upper_right_arm_m = make_live_right_upper_arm(dead_right_upper_arm)
    vf = VitalForce.new(10)

    arm_surgery_m = fn m1, m2 -> map2_m(m1, m2, &arm_surgery/2) end
    right_arm_m = arm_surgery_m.(lower_right_arm_m, upper_right_arm_m)

    {live_right_arm, remaining_from_right_arm} = M.run_m(right_arm_m, vf)

    assert live_right_arm ==
             LiveRightArm.new(
               LiveRightLowerArm.new("Tom", VitalForce.new(1)),
               LiveRightUpperArm.new("Jerry", VitalForce.new(1))
             )

    assert remaining_from_right_arm == VitalForce.new(8)
  end

  test "live head" do
    dead_brain = DeadBrain.new("Abby Normal")
    skull = Skull.new("Yorick")

    live_brain_m = make_live_brain_m(dead_brain)
    skull_m = M.return_m(skull)

    head_surgery_m = fn m1, m2 -> map2_m(m1, m2, &head_surgery/2) end
    head_m = head_surgery_m.(live_brain_m, skull_m)

    vf = VitalForce.new(10)

    {live_head, remaining_from_head} = M.run_m(head_m, vf)

    assert live_head ==
             LiveHead.new(LiveBrain.new("Abby Normal", VitalForce.new(1)), Skull.new("Yorick"))

    assert remaining_from_head == VitalForce.new(9)
  end
end
