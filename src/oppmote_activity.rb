java.lang.System.out.println 'require ruboto'

require 'ruboto.rb'

java.lang.System.out.println 'improts'

ruboto_import_widgets :LinearLayout, :ListView
java_import "android.content.Intent"
java_import "org.ruboto.RubotoService"

class OppmoteActivity
  def onCreate(bundle)
    super
    java.lang.System.out.println 'inside handle create'
    setTitle 'RJJK Oppmøte'

    set_content_view do
      linear_layout :orientation => LinearLayout::VERTICAL do
        @list_view = list_view :list => ['Gupper', 'Treninger'], :id => 42
      end
    end

    startService(Intent.new($activity.application_context, Java::no.jujutsu.android.oppmote.WifiDetectorService.java_class))
  end

  def onItemClick(parent, view, position, id)
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
