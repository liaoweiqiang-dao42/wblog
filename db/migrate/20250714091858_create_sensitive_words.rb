class CreateSensitiveWords < ActiveRecord::Migration[7.1]
  def change
    create_table :sensitive_words do |t|
      t.string :word, null: false
      t.text :description
      t.boolean :enabled, default: true, null: false
      t.integer :severity, default: 1, null: false # 1: 轻微, 2: 中等, 3: 严重

      t.timestamps
    end
    
    add_index :sensitive_words, :word, unique: true
    add_index :sensitive_words, :enabled
    add_index :sensitive_words, :severity
  end
end
