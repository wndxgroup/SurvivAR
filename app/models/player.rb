class Player < CDQManagedObject

  def sorted_accounts
    self.accounts.array.sort{|a,b|a.created_on <=> b.created_on}
  end

end