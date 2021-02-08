class NotesController < ApplicationController
  before_action :set_note, only: %i[ show edit update destroy download]
  before_action :set_books, only: %i[ new create edit update ]
  before_action :authenticate_user!

  # GET /notes or /notes.json
  def index
    # @notes = Note.all
    # users can only see their notes
    @notes = current_user.notes

    if params[:search] && params[:search] != ""
      @notes =  @notes.joins(:action_text_rich_text)
             .where("action_text_rich_texts.body LIKE ? OR title LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end
  end

  # GET /notes/1 or /notes/1.json
  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@note.title}",
        page_size: 'A4',
        template: "notes/show.html.erb",
        layout: "pdf.html",
        orientation: "Portrait",
        lowquality: true,
        zoom: 1,
        dpi: 75
      end
    end
  end

  # GET /notes/new
  def new
    @note = Note.new
  end

  # GET /notes/1/edit
  def edit
  end

  # POST /notes or /notes.json
  def create
    @note = Note.new(note_params)

    respond_to do |format|
      if @note.save
        format.html { redirect_to @note, notice: "Note was successfully created." }
        format.json { render :show, status: :created, location: @note }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notes/1 or /notes/1.json
  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to @note, notice: "Note was successfully updated." }
        format.json { render :show, status: :ok, location: @note }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1 or /notes/1.json
  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to notes_url, notice: "Note was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def download
    html = render_to_string(:action => :show, :layout => "pdf.html") 
    pdf = WickedPdf.new.pdf_from_string(html) 
  
    send_data(pdf, 
      :filename => "#{@note.title}.pdf", 
      :disposition => 'attachment') 
  end

  def download_all
    @notes = current_user.notes
    html = ""
    @notes.each do |note|
      @note = Note.find(note.id)
      # html << "<h1>#{note.title}</h1>
      #           #{note.content}<br>
      #           <small>#{note.updated_at}</small><hr>"
      html << render_to_string(:action => :show, :layout => "pdf.html") 
    end
    pdf = WickedPdf.new.pdf_from_string(html) 
  
    send_data(pdf, 
      :filename => "#{current_user.email}-notes.pdf", 
      :disposition => 'attachment') 
  end

  def download_all_notes_from_book
    @book = current_user.books.find(params[:id])
    html = ""
    @book.notes.each do |note|
      @note = Note.find(note.id)
      # html << "<h1>#{note.title}</h1>
      #           #{note.content}<br>
      #           <small>#{note.updated_at}</small><hr>"
      html << render_to_string(:action => :show, :layout => "pdf.html")
    end
    pdf = WickedPdf.new.pdf_from_string(html) 
  
    send_data(pdf, 
      :filename => "#{@book.name}-notes.pdf", 
      :disposition => 'attachment') 
  end

  def download_all_separately
    # no funciona, no se puede llamar muchas veces a wicked_pdf en una sola acción
    @notes = current_user.notes
    @notes.each do |note|
      @note = Note.find(note.id)
      html = render_to_string(:action => :show, :layout => "pdf.html") 
      pdf = WickedPdf.new.pdf_from_string(html) 
      send_data(pdf, 
        :filename => "#{note.book.name}-#{note.title}.pdf", 
        :disposition => 'attachment')
      sleep 1.5
    end
    return
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = current_user.notes.find(params[:id])
    end

    def set_books
      @books = current_user.books
    end

    # Only allow a list of trusted parameters through.
    def note_params
      params.require(:note).permit(:title, :book_id, :content, :search)
    end

end
