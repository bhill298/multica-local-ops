-- Run with psql -f in an empty disposable database.
\set ON_ERROR_STOP on
CREATE TABLE public."user" (
    id integer PRIMARY KEY,
    email text NOT NULL UNIQUE,
    onboarding_questionnaire jsonb,
    updated_at timestamptz NOT NULL DEFAULT now()
);
INSERT INTO public."user" VALUES
    (1, 'owner@example.test', NULL, now()),
    (2, 'other@example.test', '{}', now());
\set owner_email owner@example.test
\ir ../hyperv/owner-prompt-defaults.sql
DO $$
BEGIN
    IF (SELECT onboarding_questionnaire FROM public."user" WHERE id = 1) IS DISTINCT FROM
       '{"version":2,"source_skipped":true,"role_skipped":true,"use_case_skipped":true}'::jsonb THEN
        RAISE EXCEPTION 'Fresh owner defaults missing on older schema';
    END IF;
END $$;

ALTER TABLE public."user" ADD star_prompt_shown_count integer NOT NULL DEFAULT 0,
                           ADD star_prompt_starred_at timestamptz;
UPDATE public."user" SET onboarding_questionnaire =
    '{"source":"search","role_other":"custom","use_case":[],"version":2,"extra":7}' WHERE id = 1;
\ir ../hyperv/owner-prompt-defaults.sql
CREATE TEMP TABLE after_first AS SELECT * FROM public."user";
\ir ../hyperv/owner-prompt-defaults.sql
DO $$
BEGIN
    IF EXISTS (SELECT * FROM public."user" EXCEPT SELECT * FROM after_first) THEN
        RAISE EXCEPTION 'Second run changed account state';
    END IF;
    IF NOT EXISTS (SELECT FROM public."user" WHERE id = 1 AND star_prompt_shown_count = 2
                   AND star_prompt_starred_at IS NULL AND onboarding_questionnaire =
                   '{"source":"search","role_other":"custom","use_case":[],"use_case_skipped":true,"version":2,"extra":7}') THEN
        RAISE EXCEPTION 'Existing answer, custom field or prompt state was lost';
    END IF;
    IF NOT EXISTS (SELECT FROM public."user" WHERE id = 2 AND star_prompt_shown_count = 0
                   AND onboarding_questionnaire = '{}') THEN
        RAISE EXCEPTION 'Unrelated user was changed';
    END IF;
END $$;
