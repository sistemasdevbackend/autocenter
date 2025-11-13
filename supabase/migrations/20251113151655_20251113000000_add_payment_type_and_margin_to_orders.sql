/*
  # Agregar Tipo de Pago y Margen de Utilidad a Orders

  1. Nuevos Campos en orders
    - `payment_type` (text) - Tipo de pago: 'contado', '6_meses', '12_meses', etc
    - `profit_margin_percentage` (decimal) - Porcentaje de margen de utilidad aplicado
    - `payment_description` (text) - Descripción del tipo de pago/financiamiento

  2. Propósito
    - Registrar el tipo de pago seleccionado por el cliente
    - Almacenar el margen de utilidad aplicado
    - Facilitar reportes y análisis de rentabilidad

  3. Seguridad
    - RLS ya habilitado en orders
    - Políticas existentes cubren estos campos
*/

-- Agregar campo payment_type
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'orders' AND column_name = 'payment_type'
  ) THEN
    ALTER TABLE orders ADD COLUMN payment_type text;
  END IF;
END $$;

-- Agregar campo profit_margin_percentage
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'orders' AND column_name = 'profit_margin_percentage'
  ) THEN
    ALTER TABLE orders ADD COLUMN profit_margin_percentage numeric(5, 2) DEFAULT 0;
  END IF;
END $$;

-- Agregar campo payment_description
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'orders' AND column_name = 'payment_description'
  ) THEN
    ALTER TABLE orders ADD COLUMN payment_description text;
  END IF;
END $$;

-- Crear índice para consultas por tipo de pago
CREATE INDEX IF NOT EXISTS idx_orders_payment_type ON orders(payment_type);

-- Comentarios para documentación
COMMENT ON COLUMN orders.payment_type IS 'Tipo de pago seleccionado: contado, 6_meses, 12_meses, etc';
COMMENT ON COLUMN orders.profit_margin_percentage IS 'Porcentaje de margen de utilidad aplicado al presupuesto';
COMMENT ON COLUMN orders.payment_description IS 'Descripción del tipo de pago o financiamiento';