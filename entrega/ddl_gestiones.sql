-- Core: notas de gestión de cobranza (entrada de la Lambda Bedrock).
CREATE TABLE IF NOT EXISTS core.gestiones_cobranza (
    gestion_id BIGSERIAL PRIMARY KEY,
    credito_id BIGINT NOT NULL REFERENCES core.creditos(credito_id),
    cliente_id UUID NOT NULL REFERENCES core.clientes(cliente_id),
    fecha_gestion TIMESTAMPTZ NOT NULL,
    canal_contacto VARCHAR(20) NOT NULL,
    texto_nota TEXT NOT NULL
);
