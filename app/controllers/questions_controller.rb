class QuestionsController < ApplicationController
  
  

  def create
    # Using the global GEMINI_CLIENT constant initialized in the initializer
    contents = {
      contents: [
        {
          role: 'user',
          parts: {
            text: 'Actúa como un vendedor experto en nuestra tienda de ropa. Responde a las preguntas de los clientes de forma amigable y profesional, proporcionando información detallada sobre los productos del catálogo, incluyendo precios, disponibilidad y características. Si el cliente solicita una recomendación, sugiere productos que se adapten a sus necesidades. Evita respuestas que no estén relacionadas con la venta de productos.'+
            '\nSolidus T-Shirt - $19.99 - 20 unidades'+
            '\nSolidus Long Sleeve - $19.99 - 20 unidades'+
            '\nSolidus Women\'s T-Shirt - $19.99 - 20 unidades'+
            '\nSolidus Snapback Cap - $15.99 - 20 unidades'+
            '\nSolidus Hoodie Zip - $29.99 - 20 unidades'+
            '\nRuby Hoodie - $29.99 - 20 unidades'+
            '\nRuby Hoodie Zip - $29.99 - 20 unidades'+
            '\nRuby Polo - $26.99 - 20 unidades'+
            '\nSolidus Mug - $9.99 - 20 unidades'+
            '\nRuby Mug - $9.99 - 20 unidades'+
            '\nSolidus Tote - $15.99 - 20 unidades'+
            '\nRuby Tote - $15.99 - 20 unidades'
          }
        },
          {
          role: 'user',
          parts: {
            text: question # Use the user's question
          }
        }
      ]
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
      # format.html { redirect_to questions_path, notice: 'Answer was successfully generated.' }
      format.html { head :no_content }  # Asegurarse de que no haya redirección ni carga completa de la página
    end 

  rescue => e
    @answer = "Error: #{e.message}"
    Rails.logger.error("Gemini AI Error: #{e.message}")
    format.turbo_stream  # Asegurarnos de que respondemos con Turbo Stream también en caso de error
    format.html { head :no_content }  # Evitar redirección en caso de error
    
  end

  private

  # Extracts the question parameter from the form
  def question
    params[:question][:question]
  end
end