class Hash
  def assert_valid_keys_and_reverse_merge!(other_hash)
    assert_valid_keys(*other_hash.keys)
    reverse_merge! other_hash
  end

  def assert_valid_keys_and_recursive_reverse_merge!(other_hash)
    assert_valid_keys(*other_hash.keys)
    recursive_reverse_merge! other_hash
  end

  def recursive_merge(other_hash)
    merge(other_hash) do |key, oldval, newval|
      oldval.is_a?(Hash) && newval.is_a?(Hash) ? oldval.recursive_merge(newval) : newval
    end
  end

  def recursive_merge!(other_hash)
    merge!(other_hash) do |key, oldval, newval|
      oldval.is_a?(Hash) && newval.is_a?(Hash) ? oldval.recursive_merge!(newval) : newval
    end
  end

  def recursive_reverse_merge(other_hash)
    other_hash.recursive_merge self
  end

  def recursive_reverse_merge!(other_hash)
    replace recursive_reverse_merge(other_hash)
  end
end