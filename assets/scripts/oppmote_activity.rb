require 'ruboto.rb'

ruboto_import_widgets :LinearLayout, :ListView
java_import "android.content.Intent"

$activity.handle_create do |bundle|
  setTitle 'RJJK Oppmøte'

  setup_content do
    linear_layout :orientation => LinearLayout::VERTICAL do
      @list_view = list_view :list => ['Gupper', 'Treninger'], :id => 42
    end
  end

  handle_item_click do |parent, view, position, id|
    toast "Item Click: #{view.text}"
    model = {
      'Gupper' => 'Group',
      'Treninger' => 'GroupSchedule',
    }[view.text]
    i = Intent.new
    i.setClassName("no.jujutsu.android.oppmote", "no.jujutsu.android.oppmote.#{model}List")
    startActivity(i)
  end


end
