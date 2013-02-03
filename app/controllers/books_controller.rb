class BooksController < ApplicationController
  # GET /books
  # GET /books.json
  def index
    @books = Book.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @books }
    end
  end

  # GET /books/1
  # GET /books/1.json
  def show
    @book = Book.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @book }
    end
  end

  # GET /books/new
  # GET /books/new.json
  def new
    @book = Book.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @book }
    end
  end

  # GET /books/1/edit
  def edit
    @book = Book.find(params[:id])
  end

  # POST /books
  # POST /books.json
  def create
    status = true
    begin
      Book.transaction do
        @book = Book.new(params[:book])
        @book.save!
        #ディレクトリ作成
        FileUtils.mkdir_p("./public/images/") unless FileTest.exist?("./public/images/")
        FileUtils.mkdir_p("./public/images/#{@book.id}/") unless FileTest.exist?("./public/images/#{@book.id}/")
        num = 1;
        params['imagenum'].to_i.times{|index|
          params[:imagefile][index.to_s].each{|file|
            FileUtils.mkdir_p("./public/images/#{@book.id}/#{num}") unless FileTest.exist?("./public/images/#{@book.id}/#{num}")
            #ファイルの作成
            File.open("./public/images/#{@book.id}/#{num}/#{file.original_filename}", 'wb') do |of|
              of.write(file.read)
            end
            image =Image.new({:filename => file.original_filename,:index => num,:book_id => @book.id})
            image.save!
            num = num + 1
          }if params[:imagefile][index.to_s].present?
        }
      end
    rescue
      status = false
      #ファイルの削除
      deleteall("./public/images/#{@book.id}/") if FileTest.exist?("./public/images/#{@book.id}/") == true
    end
    respond_to do |format|
      if status == true then
          format.html { redirect_to @book, notice: 'Book was successfully created.' }
          format.json { render json: @book, status: :created, location: @book }
      else
          format.html { render action: "new" }
          format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /books/1
  # PUT /books/1.json
  def update

    status = true
    begin
      Book.transaction do

        @book = Book.find(params[:id])
        @book.update_attributes!(params[:book])
        #ディレクトリ作成
        FileUtils.mkdir_p("./public/images/") unless FileTest.exist?("./public/images/")
        FileUtils.mkdir_p("./public/images/#{@book.id}/") unless FileTest.exist?("./public/images/#{@book.id}/")
        #チェックされていないファイルは削除
        selectImages = []
        selectImages = params[:images] if params[:images].present?
        (@book.images).each{|image|
          next if selectImages.include?(image.id.to_s) == true
            #ファイルの削除
            deleteall("./public/images/#{@book.id}/#{image.index}/") if FileTest.exist?("./public/images/#{@book.id}/#{image.index}/") == true
            #レコード削除
            image.destroy
        }
        dirs = Dir::entries("./public/images/#{@book.id}/")

        dirs.delete('.')
        dirs.delete('..')
        dirs << '1'
        num = dirs.map{|data|data.to_i}.max + 1

        params['imagenum'].to_i.times{|index|
          params[:imagefile][index.to_s].each{|file|
            FileUtils.mkdir_p("./public/images/#{@book.id}/#{num}") unless FileTest.exist?("./public/images/#{@book.id}/#{num}")
            #ファイルの作成
            File.open("./public/images/#{@book.id}/#{num}/#{file.original_filename}", 'wb') do |of|
              of.write(file.read)
            end
            image =Image.new({:filename => file.original_filename,:index => num,:book_id => @book.id})
            image.save!
            num = num + 1
          }if params[:imagefile][index.to_s].present?
        }
      end
    rescue
      status = false
      #ファイルの削除
      deleteall("./public/images/#{@book.id}/") if FileTest.exist?("./public/images/#{@book.id}/") == true
    end
    respond_to do |format|
      if status == true
        format.html { redirect_to @book, notice: 'Book was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book = Book.find(params[:id])
    #画像情報の削除
    @book.images.each{|image|
      image.destroy
    }
    #ディレクトリの削除
    deleteall("./public/images/#{@book.id}/") if FileTest.exist?("./public/images/#{@book.id}/") == true
    #本情報の削除
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url }
      format.json { head :no_content }
    end
  end
  def download
    image = Image.find(params[:id])
    send_file( "./public/images/#{params[:showid]}/#{image.index}/#{image.filename}", :filename => image.filename)
  end
end
