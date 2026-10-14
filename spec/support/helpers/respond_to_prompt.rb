module RespondToPrompt
  def respond_to_prompt(with: nil)
    allow($stdin).to receive(:tty?).and_return(true)
    eval <<~RUBY
      expect(Thor::LineEditor).to receive(:readline)#{'.and_return(with)' if with.present?}#{'.and_yield' if block_given?}
    RUBY
  end
end
