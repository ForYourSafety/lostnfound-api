# frozen_string_literal: true

class TagPolicy # rubocop:disable Style/Documentation
  def initialize(requestor, tag)
    @requestor = requestor
    @tag = tag
  end

  def can_create?
    true
  end

  def can_view?
    true
  end

  def can_update?
    false # tag model has no creator column, so we assume tags are not editable
  end

  def can_delete?
    false # tag model has no creator column, so we assume tags are not deletable
  end

  def can_add_to_item?(item)
    item.creator == @requestor
  end

  def can_remove_from_item?(item)
    item.creator == @requestor
  end

  def summary
    {
      can_create: can_create?,
      can_view: can_view?,
      can_update: can_update?,
      can_delete: can_delete?,
      can_add_to_item: can_add_to_item?(item),
      can_remove_from_item: can_remove_from_item?(item)
    }
  end
end
