def assert_raise(*exp)
  begin
    yield
    'Nothing raised!'
  rescue Exception => e
    expected = exp.any? { |ex| e.is_a? ex }
    if expected
      true
    else
      "Got #{e.inspect} raised!"
    end
  end
end
