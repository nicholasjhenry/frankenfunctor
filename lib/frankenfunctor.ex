defmodule Frankenfunctor do
  defmodule VitalForce do
    @type t :: {:units, integer}

    @spec new(integer) :: t
    def new(value), do: {:units, value}

    @spec get_vital_force(t) :: {t, t}
    def get_vital_force(vital_source) do
      one_unit = new(1)

      {
        one_unit,
        sub(vital_source, one_unit)
      }
    end

    @spec sub(t, t) :: t
    def sub({:units, lhs}, {:units, rhs}) do
      new(lhs - rhs)
    end
  end

  defmodule Label do
    @type t :: String.t()
  end

  defmodule DeadLeftLeg do
    @type t :: {:dead_left_leg, Label.t()}

    @spec new(Label.t()) :: t
    def new(label), do: {:dead_left_leg, label}
  end

  defmodule LiveLeftLeg do
    @type t :: {{:live_left_leg, Label.t()}, VitalForce.t()}

    @spec new(Label.t(), VitalForce.t()) :: t
    def new(label, vital_force) do
      {{:live_left_leg, label}, vital_force}
    end
  end

  defmodule M do
    @type t(live_body_part) :: {:m, (VitalForce.t() -> {live_body_part, VitalForce})}

    def new(func) do
      {:m, func}
    end
  end

  @spec make_live_left_leg_m(DeadLeftLeg.t()) :: M.t(LiveLeftLeg.t())
  def make_live_left_leg_m(dead_left_leg) do
    become_alive = fn vital_force ->
      {:dead_left_leg, label} = dead_left_leg
      {one_unit, remain_vital_force} = VitalForce.get_vital_force(vital_force)
      live_left_leg = LiveLeftLeg.new(label, one_unit)

      {live_left_leg, remain_vital_force}
    end

    M.new(become_alive)
  end
end
