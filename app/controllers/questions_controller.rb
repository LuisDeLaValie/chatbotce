class QuestionsController < ApplicationController
  # Inicializa el historial en cada solicitud
  def create
    # Construye el historial comenzando con el mensaje inicial
    history = build_initial_history
    # Agrega la pregunta actual al historial
    history << { role: 'user', parts: { text: question } }

    # Estructura de contenido para Gemini AI
    contents = {
      contents: history # Pasa todo el historial
    }

    @answer = "" # Variable para acumular la respuesta

    # Define el bloque para manejar la respuesta en streaming
    stream_proc = Proc.new do |part_text, _event, _parsed, _raw|
      @answer += part_text # Acumula la respuesta
    end

    # Llama a Gemini AI con el historial
    GEMINI_CLIENT.stream_generate_content(contents, model: 'gemini-1.5-flash', stream: true, &stream_proc)

    # Agrega la respuesta del asistente al historial
    history << { role: 'assistant', parts: { text: @answer } }

    # Responde con Turbo Stream o HTML
    respond_to do |format|
      format.turbo_stream
      format.html { head :no_content }
    end
  rescue => e
    @answer = "Error: #{e.message}"
    Rails.logger.error("Gemini AI Error: #{e.message}")

    respond_to do |format|
      format.turbo_stream
      format.html { head :no_content }
    end
  end

  private

  # Construye el historial inicial con el mensaje base
  def build_initial_history
    [
      {
        role: 'user',
        parts: {
          text: 'Actúa como un vendedor experto en nuestra tienda de ropa. Responde a las preguntas de los clientes de forma amigable y profesional, proporcionando información detallada sobre los productos del catálogo, incluyendo precios, disponibilidad y características. Si el cliente solicita una recomendación, sugiere productos que se adapten a sus necesidades. Evita respuestas que no estén relacionadas con la venta de productos. Si hace una pregunta relacionada con los productos y no cuentas con la información, puedes inventar dicha información.\n' +
                '\nSolidus T-Shirt - $19.99 - 20 unidades' +
                '\nSolidus Long Sleeve - $19.99 - 20 unidades' +
                '\nSolidus Women\'s T-Shirt - $19.99 - 20 unidades' +
                '\nSolidus Snapback Cap - $15.99 - 20 unidades' +
                '\nSolidus Hoodie Zip - $29.99 - 20 unidades' +
                '\nRuby Hoodie - $29.99 - 20 unidades' +
                '\nRuby Hoodie Zip - $29.99 - 20 unidades' +
                '\nRuby Polo - $26.99 - 20 unidades' +
                '\nSolidus Mug - $9.99 - 20 unidades' +
                '\nRuby Mug - $9.99 - 20 unidades' +
                '\nSolidus Tote - $15.99 - 20 unidades' +
                '\nRuby Tote - $15.99 - 20 unidades'
        }
      }
    ]
  end

  # Extrae la pregunta del formulario
  def question
    params[:question][:question]
  end
end
