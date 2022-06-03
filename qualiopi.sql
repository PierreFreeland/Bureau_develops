UPDATE goxygene_document_types SET "label" = 'Contrat / Convention signé(e)' where id = 121;

ALTER TABLE goxygene_consultants ADD COLUMN IF NOT EXISTS "qualiopi" BOOLEAN NOT NULL DEFAULT FALSE;

INSERT INTO goxygene_document_types (id, document_kind_id, "label", filename, s3_path, created_by, updated_by) VALUES
(5052, 4, 'Mon offre de formation', 'OffreFormation', 'commercial_contracts', 296, 296),
(5053, 4, 'Demande / Besoin formation', 'DemandeBesoinFormation', 'commercial_contracts', 296, 296),
(5054, 4, 'Evaluation acquis début formation', 'EvalAcquisFormation', 'commercial_contracts', 296, 296),
(5055, 4, 'Programme', 'ProgrammeFormation', 'commercial_contracts', 296, 296),
(5056, 4, 'Convocation', 'ConvocationFormation', 'commercial_contracts', 296, 296),
(5057, 4, 'Certification (optionnel)', 'CertifFormation', 'commercial_contracts', 296, 296),
(5058, 4, 'Lieu Formation', 'LieuFormation', 'commercial_contracts', 296, 296),
(5059, 4, 'Handicap (optionnel)', 'HandicapFormation', 'commercial_contracts', 296, 296),
(5060, 4, 'Feuilles présence', 'PresenceFormation', 'commercial_contracts', 296, 296),
(5061, 4, 'Supports formation', 'SupportFormation', 'commercial_contracts', 296, 296),
(5062, 4, 'Evaluation compétences', 'EvalCompFormation', 'commercial_contracts', 296, 296),
(5063, 4, 'Evaluation satisfaction stagiaires', 'EvalSatisfStagFormation', 'commercial_contracts', 296, 296),
(5064, 4, 'Evaluation satisfaction commanditaire', 'EvalSatisCommFormation', 'commercial_contracts', 296, 296),
(5065, 4, 'Evaluation satisfaction financeur', 'EvalSatisFinancFormation', 'commercial_contracts', 296, 296),
(5066, 4, 'Certificat réalisation', 'CertifRealFormation', 'commercial_contracts', 296, 296),
(5067, 4, 'Preuve envoi docs aux stagiaires', 'PreuveDocFormation', 'commercial_contracts', 296, 296),
(5068, 4, 'Amélioration continue', 'AmelContFormation', 'commercial_contracts', 296, 296),
(5069, 4, 'Evaluation à froid', 'EvalFroidFormation', 'commercial_contracts', 296, 296),
(5070, 4, 'Veille', 'VeilleFormation', 'commercial_contracts', 296, 296);
