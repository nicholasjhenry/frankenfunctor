defmodule FrankenfunctorTest do
  use ExUnit.Case

  alias Frankenfunctor.{DeadLeftLeg, LiveLeftLeg, VitalForce}

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
end
