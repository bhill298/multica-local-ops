-- Only the owner enrolled by this installer, in this instance's database.
BEGIN;
SELECT id AS owner_id FROM public."user" WHERE email = :'owner_email' FOR UPDATE
\gset

-- Multica's onboarding API replaces the whole questionnaire. Merge only
-- missing skip flags, preserving other answers and any unknown fields.
WITH account AS (
    SELECT COALESCE(NULLIF(onboarding_questionnaire, 'null'::jsonb), '{}'::jsonb) AS answers
    FROM public."user" WHERE id = :'owner_id'
), missing AS (
    SELECT jsonb_object_agg(field || '_skipped', true) AS flags
    FROM account CROSS JOIN (VALUES ('source'), ('role'), ('use_case')) AS questions(field)
    WHERE jsonb_typeof(answers) = 'object'
      AND COALESCE(answers ->> 'version', '2') IN ('1', '2')
      AND COALESCE(answers -> field, 'null'::jsonb) IN ('null', '""', '[]')
      AND COALESCE(answers ->> (field || '_other'), '') = ''
      AND (answers -> (field || '_skipped')) IS DISTINCT FROM 'true'::jsonb
)
UPDATE public."user"
SET onboarding_questionnaire = '{"version":2}'::jsonb || account.answers || missing.flags,
    updated_at = now()
FROM account, missing
WHERE id = :'owner_id' AND missing.flags IS NOT NULL;

-- Older releases do not have the star prompt. v0.11.1 stops offering it
-- after two showings. Leave the user's actual star-click timestamp alone.
SELECT EXISTS (
    SELECT FROM information_schema.columns WHERE table_schema = 'public'
    AND table_name = 'user' AND column_name = 'star_prompt_shown_count'
) AS has_star_prompt
\gset
\if :has_star_prompt
UPDATE public."user" SET star_prompt_shown_count = 2, updated_at = now()
WHERE id = :'owner_id' AND star_prompt_shown_count < 2 AND star_prompt_starred_at IS NULL;
\endif
COMMIT;
