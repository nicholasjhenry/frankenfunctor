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

  defmodule DeadLeftBrokenArm do
    @type t :: {:dead_left_broken_arm, Label.t()}

    @spec new(Label.t()) :: t
    def new(label), do: {:dead_left_broken_arm, label}
  end

  defmodule LiveLeftLeg do
    @type t :: {{:live_left_leg, Label.t()}, VitalForce.t()}

    @spec new(Label.t(), VitalForce.t()) :: t
    def new(label, vital_force) do
      {{:live_left_leg, label}, vital_force}
    end
  end

  defmodule LiveLeftBrokenArm do
    @type t :: {{:live_left_broken_arm, Label.t()}, VitalForce.t()}

    def new(label, vital_force) do
      {{:live_left_broken_arm, label}, vital_force}
    end
  end

  defmodule LiveLeftArm do
    @type t :: {{:live_left_arm, Label.t()}, VitalForce.t()}

    def new(label, vital_force) do
      {{:live_left_arm, label}, vital_force}
    end
  end

  defmodule M do
    @type t(live_body_part) :: {:m, (VitalForce.t() -> {live_body_part, VitalForce})}

    def new(func) do
      {:m, func}
    end

    def run_m({:m, func}, vf) do
      func.(vf)
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

  @spec heal_broken_arm(LiveLeftBrokenArm.t()) :: LiveLeftArm.t()
  def heal_broken_arm({{:live_left_broken_arm, label}, vf}), do: LiveLeftArm.new(label, vf)

  @spec make_healed_left_arm(M.t(LiveLeftBrokenArm.t())) :: M.t(LiveLeftArm.t())
  def make_healed_left_arm(broken_arm_m) do
    heal_while_alive = fn vital_force ->
      {broken_arm, remaining_vital_force} = M.run_m(broken_arm_m, vital_force)
      healed_arm = heal_broken_arm(broken_arm)

      {healed_arm, remaining_vital_force}
    end

    M.new(heal_while_alive)
  end

  @spec map_m(M.t(a :: any), (a :: any -> b :: any)) :: M.t(b :: any)
  def map_m(body_part_m, func) do
    transform_while_alive = fn vital_force ->
      {body_part, remaining_vital_force} = M.run_m(body_part_m, vital_force)
      updated_body_part = func.(body_part)

      {updated_body_part, remaining_vital_force}
    end

    M.new(transform_while_alive)
  end

  def heal_broken_arm_m(heal_broken_arm) do
    fn body_part_m -> map_m(body_part_m, heal_broken_arm) end
  end

  def make_live_left_broken_arm(dead_left_broken_arm) do
    {:dead_left_broken_arm, label} = dead_left_broken_arm

    become_alive = fn vital_force ->
      {one_unit, remaining_vital_force} = VitalForce.get_vital_force(vital_force)
      live_left_broken_arm = LiveLeftBrokenArm.new(label, one_unit)
      {live_left_broken_arm, remaining_vital_force}
    end

    M.new(become_alive)
  end
end
