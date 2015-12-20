activity Java::no.jujutsu.android.oppmote.OppmoteActivity

setup do |activity|
  start = Time.now
  loop do
    @text_view = activity.findViewById(42)
  puts "@text_view: #{@text_view}"
    break if @text_view || (Time.now - start > 60)
    sleep 1
  end
  assert @text_view
end

test('initial setup') do |activity|
  begin
    assert_equal 'What hath Matz wrought?', @text_view.text
  rescue
    fail $!.message
  end
end

test('button changes text') do |activity|
  button = activity.findViewById(43)
  button.performClick
  assert_equal 'What hath Matz wrought!', @text_view.text
end
