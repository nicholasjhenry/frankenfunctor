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
end
