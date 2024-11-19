class QuestionsController < ApplicationController
  def create
    # Using the global GEMINI_CLIENT constant initialized in the initializer
    contents = {
      contents: {
        role: 'user',
        parts: {
          text: question  # Use the user's question
        }
      }
    }

    # Variable to accumulate the streamed response
    @answer = ""

    # Define the block to handle streaming
    stream_proc = Proc.new do |part_text, _event, _parsed, _raw|
      @answer += part_text  # Append each part of the response to @answer
    end

    # Send the question to Gemini AI with streaming enabled
    GEMINI_CLIENT.stream_generate_content(contents, model: 'gemini-1.5-flash', stream: true, &stream_proc)

    # Respond with Turbo Stream or HTML (if Turbo Stream fails)
    respond_to do |format|
      format.turbo_stream  # Renders a turbo_stream response
      format.html { redirect_to questions_path, notice: 'Answer was successfully generated.' }
    end

  rescue => e
    @answer = "Error: #{e.message}"
    Rails.logger.error("Gemini AI Error: #{e.message}")
  end

  private

  # Extracts the question parameter from the form
  def question
    params[:question][:question]
  end
end