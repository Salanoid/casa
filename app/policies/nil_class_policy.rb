class NilClassPolicy < ApplicationPolicy
class NilClassPolicy < ApplicationPolicy
  def method_missing(*)
    false
  end
end
