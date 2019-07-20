defmodule FrankenfunctorTest do
  use ExUnit.Case

  alias Frankenfunctor.VitalForce

  test "getting vital force" do
    vital_force = VitalForce.new(10)

    {actual_vital_force, remaining_vital_force} = VitalForce.get_vital_force(vital_force)

    assert actual_vital_force == VitalForce.new(1)
    assert remaining_vital_force == VitalForce.new(9)
  end
end
