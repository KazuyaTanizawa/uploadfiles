class ApplicationController < ActionController::Base
  protect_from_forgery

  def deleteall(delthem)
    if FileTest.directory?(delthem) then  # ディレクトリかどうかを判別
      Dir.foreach( delthem ) do |file|    # 中身を一覧
        next if /^\.+$/ =~ file           # 上位ディレクトリと自身を対象から外す
        deleteall( delthem.sub(/\/+$/,"") + "/" + file )
      end
      Dir.rmdir(delthem) rescue ""        # 中身が空になったディレクトリを削除
    else
      File.delete(delthem)                # ディレクトリでなければ削除
    end
  end
end
