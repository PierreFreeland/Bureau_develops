INSERT INTO public.goxygene_modules ("id", "active", "name", "created_at", "created_by", "updated_at", "updated_by")
  select 25, true, 'Bureau Client', NOW(), 296, NOW(), 296 from goxygene_modules where not exists (select * from goxygene_modules where name = 'Bureau Client') limit 1;

CREATE TYPE article_bureau_enum AS ENUM (
  'consultant',
  'client'
);

ALTER TABLE goxygene_articles ADD COLUMN IF NOT EXISTS "bureau" public.article_bureau_enum NOT NULL DEFAULT 'consultant';
ALTER TABLE goxygene_article_topics ADD COLUMN IF NOT EXISTS "bureau" public.article_bureau_enum NOT NULL DEFAULT 'consultant';
