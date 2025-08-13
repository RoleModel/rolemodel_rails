module RespondToPrompt
  def respond_to_prompt(with: nil)
    eval <<~RUBY
      expect(Thor::LineEditor).to receive(:readline)#{'.and_return(with)' if with.present?}#{'.and_yield' if block_given?}
    RUBY
  end
end
