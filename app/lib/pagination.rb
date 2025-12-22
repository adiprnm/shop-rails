class Pagination
  attr_reader :scope, :next_page, :previous_page, :has_next_page, :has_previous_page

  def initialize(scope)
    @scope = scope
    @next_page = nil
    @previous_page = nil
    @has_next_page = false
    @has_previous_page = false
  end

  def paginate(page: 1, per_page: 15)
    @next_page = page + 1
    @previous_page = page - 1
    offset = @previous_page * per_page
    @has_next_page = scope.limit(per_page).offset(offset + per_page).any?
    @has_previous_page = page > 1

    [ scope.limit(per_page).offset(offset), self ]
  end
end
