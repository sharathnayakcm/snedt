class Grid::PaymentsPresenter < Grid::BasePresenter

  def initialize(template, options = {})
    initialize_template template
    super(
      template,
      options.reverse_merge(
        :columns => [
          {:name => "Payment #"},
          {:name => "Plan"},
          {:name => "Vendor"},
          {:name => "Amount"},
          {:name => "Date"},
          {:name => "Status"}
        ],
        :default_order => 'id asc',
        :empty => t(:no_payments_found),
        :search => true,
        :version => 2
      )
    )
  end
end
