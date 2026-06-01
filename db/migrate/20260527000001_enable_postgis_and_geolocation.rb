class EnablePostgisAndGeolocation < ActiveRecord::Migration[8.0]
  # Enables PostGIS (if available on the server) and adds geo columns to
  # users + decorators. Lat/lng remain the source of truth; `geom` is a derived
  # geography(Point, 4326) maintained by model callbacks. NearbyVendorsService
  # automatically falls back to a Haversine query if PostGIS is unavailable.
  def up
    enable_postgis = postgis_available?

    if enable_postgis
      execute "CREATE EXTENSION IF NOT EXISTS postgis;"
    else
      say "PostGIS extension not available on this server; skipping geom columns and GIST indexes.", true
    end

    # --- users ---------------------------------------------------------------
    add_column :users, :latitude,             :decimal, precision: 10, scale: 6
    add_column :users, :longitude,            :decimal, precision: 10, scale: 6
    add_column :users, :location_updated_at,  :datetime

    if enable_postgis
      execute <<~SQL.squish
        ALTER TABLE users
        ADD COLUMN geom geography(Point, 4326);
      SQL
      execute "CREATE INDEX index_users_on_geom ON users USING GIST (geom);"
    end

    # --- decorators (vendors) ------------------------------------------------
    add_column :decorators, :category, :string
    add_column :decorators, :open,     :boolean, null: false, default: true
    add_column :decorators, :location_updated_at, :datetime

    add_index :decorators, :category
    add_index :decorators, :open

    if enable_postgis
      execute <<~SQL.squish
        ALTER TABLE decorators
        ADD COLUMN geom geography(Point, 4326);
      SQL
      execute "CREATE INDEX index_decorators_on_geom ON decorators USING GIST (geom);"

      # Backfill geom from existing lat/lng on decorators.
      execute <<~SQL.squish
        UPDATE decorators
        SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography
        WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
      SQL
    end
  end

  def down
    if postgis_available?
      execute "DROP INDEX IF EXISTS index_users_on_geom;"
      execute "DROP INDEX IF EXISTS index_decorators_on_geom;"
      execute "ALTER TABLE users      DROP COLUMN IF EXISTS geom;"
      execute "ALTER TABLE decorators DROP COLUMN IF EXISTS geom;"
    end

    remove_index  :decorators, :open     if index_exists?(:decorators, :open)
    remove_index  :decorators, :category if index_exists?(:decorators, :category)
    remove_column :decorators, :location_updated_at
    remove_column :decorators, :open
    remove_column :decorators, :category

    remove_column :users, :location_updated_at
    remove_column :users, :longitude
    remove_column :users, :latitude
  end

  private

  def postgis_available?
    select_value(<<~SQL.squish).present?
      SELECT 1 FROM pg_available_extensions WHERE name = 'postgis' LIMIT 1
    SQL
  rescue ActiveRecord::StatementInvalid
    false
  end
end
