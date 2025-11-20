-- Tabela para Pacientes
CREATE TABLE `person` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  `name` VARCHAR(255) NOT NULL,
  `date_of_birth` DATE DEFAULT NULL,
  `health_number` VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
);

-- Tabela para Utilizadores do Sistema / Médicos
CREATE TABLE `account` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `professional_license` VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_UNIQUE` (`email`)
);

-- Tabela para agendamentos/consultas
CREATE TABLE `appointment` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  `patient_id` INT NOT NULL COMMENT 'FK para a tabela `person`',
  `doctor_id` INT NOT NULL COMMENT 'FK para a tabela `account`',
  `appointment_date` DATETIME NOT NULL COMMENT 'Data e hora da consulta',
  `status` ENUM('scheduled', 'completed', 'cancelled') NOT NULL DEFAULT 'scheduled',
  PRIMARY KEY (`id`),
  KEY `fk_appointment_patient_idx` (`patient_id`),
  KEY `fk_appointment_doctor_idx` (`doctor_id`),
  CONSTRAINT `fk_appointment_patient` FOREIGN KEY (`patient_id`) REFERENCES `person` (`id`),
  CONSTRAINT `fk_appointment_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `account` (`id`)
);

-- Tabela para os princípios ativos dos medicamentos
CREATE TABLE `medication_active_ingredient` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
);

-- Catálogo central de todos os medicamentos disponíveis
CREATE TABLE `medication_catalog` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  `commercial_name` VARCHAR(255) NOT NULL COMMENT 'Ex: Brufen',
  `active_ingredient_id` INT NOT NULL COMMENT 'FK para o princípio ativo. Ex: Ibuprofeno',
  `manufacturer` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_medication_active_ingredient_idx` (`active_ingredient_id`),
  CONSTRAINT `fk_medication_active_ingredient` FOREIGN KEY (`active_ingredient_id`) REFERENCES `medication_active_ingredient` (`id`)
);

-- Tabela principal da prescrição, ligada ao paciente e ao médico
CREATE TABLE `prescription` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  `patient_id` INT NOT NULL COMMENT 'FK para a tabela `person`',
  `doctor_id` INT NOT NULL COMMENT 'FK para a tabela `account`',
  `status` ENUM('active', 'expired', 'cancelled', 'completed') NOT NULL DEFAULT 'active',
  `prescription_date` DATE NOT NULL,
  `appointment_id` INT DEFAULT NULL COMMENT 'Opcional: FK para a consulta que originou a prescrição',
  `notes` TEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_prescription_patient_idx` (`patient_id`),
  KEY `fk_prescription_doctor_idx` (`doctor_id`),
  CONSTRAINT `fk_prescription_patient` FOREIGN KEY (`patient_id`) REFERENCES `person` (`id`),
  CONSTRAINT `fk_prescription_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `account` (`id`),
  CONSTRAINT `fk_prescription_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointment` (`id`)
);

-- Itens específicos de uma prescrição
CREATE TABLE `prescription_item` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL DEFAULT NULL,
  `prescription_id` INT NOT NULL,
  `medication_id` INT NOT NULL COMMENT 'FK para `medication_catalog`',
  `dose` VARCHAR(100) NOT NULL COMMENT 'Ex: 400 mg',
  `instructions` VARCHAR(255) NOT NULL COMMENT 'Ex: 1 comprimido de 8 em 8 horas',
  `start_date` DATETIME DEFAULT NULL COMMENT 'Data de início da toma',
  `end_date` DATETIME DEFAULT NULL COMMENT 'Data de fim da toma',
  `quantity` INT NOT NULL COMMENT 'Número de embalagens',
  PRIMARY KEY (`id`),
  KEY `fk_prescription_item_prescription_idx` (`prescription_id`),
  KEY `fk_prescription_item_medication_idx` (`medication_id`),
  CONSTRAINT `fk_prescription_item_prescription` FOREIGN KEY (`prescription_id`) REFERENCES `prescription` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_prescription_item_medication` FOREIGN KEY (`medication_id`) REFERENCES `medication_catalog` (`id`)
);

-- Histórico de Medicação do Paciente
CREATE TABLE `person_medication` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME DEFAULT NULL,
  
  `person_id` INT NOT NULL COMMENT 'FK para a tabela `person`',
  `prescription_item_id` INT NULL COMMENT 'FK para a linha da receita. NULL se for registo manual.',
  `medication_id` INT NOT NULL COMMENT 'FK direta para o `medication_catalog`',
  
  `dose` VARCHAR(100) NULL COMMENT 'Ex: 1 comprimido, 500mg',
  `instructions` VARCHAR(255) NULL COMMENT 'Ex: Ao pequeno-almoço, 8 em 8 horas',
  `start_date` DATE DEFAULT NULL,
  `end_date` DATE DEFAULT NULL,
  `notes` TEXT DEFAULT NULL,
  
  PRIMARY KEY (`id`),
  KEY `fk_person_med_person_idx` (`person_id`),
  KEY `fk_person_med_item_idx` (`prescription_item_id`),
  KEY `fk_person_med_med_idx` (`medication_id`),
  CONSTRAINT `fk_person_med_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`),
  CONSTRAINT `fk_person_med_item` FOREIGN KEY (`prescription_item_id`) REFERENCES `prescription_item` (`id`),
  CONSTRAINT `fk_person_med_med` FOREIGN KEY (`medication_id`) REFERENCES `medication_catalog` (`id`)
);

-- Tabela de Interações (Regras da IA)
CREATE TABLE `interaction` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME DEFAULT NULL,
  
  `active_ingredient_a_id` INT NOT NULL,
  `active_ingredient_b_id` INT NOT NULL,
  
  `severity` ENUM('minor', 'moderate', 'major', 'contraindicated') NOT NULL,
  `description` TEXT NOT NULL,
  `recommendation` TEXT DEFAULT NULL,
  
  PRIMARY KEY (`id`),
  KEY `fk_interaction_ing_a_idx` (`active_ingredient_a_id`),
  KEY `fk_interaction_ing_b_idx` (`active_ingredient_b_id`),
  CONSTRAINT `fk_interaction_ing_a` FOREIGN KEY (`active_ingredient_a_id`) REFERENCES `medication_active_ingredient` (`id`),
  CONSTRAINT `fk_interaction_ing_b` FOREIGN KEY (`active_ingredient_b_id`) REFERENCES `medication_active_ingredient` (`id`)
);

-- Adiciona campos de input do SNS à tabela `person`
ALTER TABLE person
ADD COLUMN health_subsystem_code VARCHAR(10) DEFAULT '935601' COMMENT 'Código da Entidade Financeira Responsável (SPMS Tabela 95). 935601 = SNS',
ADD COLUMN regime_comparticipacao_tipo CHAR(1) NULL COMMENT 'Tipo do regime (R=Pensionista, O=Outros) [SPMS Tabela 11]',
ADD COLUMN regime_comparticipacao_codigo VARCHAR(10) NULL COMMENT 'Código do benefício (Ex: 2001, 3001) [SPMS Tabela 11 e 101]';
ADD COLUMN gender CHAR(1) NULL COMMENT 'Sexo do utente: M=Masculino, F=Feminino [SPMS Tabela 7]';

-- Adiciona campos de output do SNS à tabela `prescription`
ALTER TABLE prescription
ADD COLUMN sns_prescription_number VARCHAR(19) NULL COMMENT 'Número único da receita gerado pelo SPMS',
ADD COLUMN sns_access_code VARCHAR(20) NULL COMMENT 'Código de acesso/PinReceita',
ADD COLUMN sns_option_code VARCHAR(20) NULL COMMENT 'Código direito de opção/PinDireitoOpcao',
ADD COLUMN sns_status VARCHAR(4) NULL DEFAULT 'EM' COMMENT 'Estado da receita no SNS. Ex: EM, DI, NA',
ADD COLUMN sns_response_log TEXT NULL COMMENT 'Log da mensagem de Resultado (sucesso ou erro) devolvida pelo SPMS';

-- Adiciona campo de output do SNS à tabela `prescription_item`
ALTER TABLE prescription_item
ADD COLUMN sns_qr_code TEXT NULL COMMENT 'Base64 do QRPresc';

-- Tabela de Alergias da Pessoa (Input da IA)
CREATE TABLE `person_allergy` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `person_id` INT NOT NULL,
  `allergen` VARCHAR(255) NOT NULL,
  `reaction` TEXT NULL,
  `severity` ENUM('mild', 'moderate', 'severe') NULL,
  
  PRIMARY KEY (`id`),
  KEY `fk_allergy_person_idx` (`person_id`),
  CONSTRAINT `fk_allergy_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`)
);

-- Tabela de Condições Clínicas da Pessoa (Input da IA)
CREATE TABLE `person_condition` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `person_id` INT NOT NULL,
  `condition_name` VARCHAR(255) NOT NULL,
  `icd10_code` VARCHAR(10) NULL,
  `onset_date` DATE NULL COMMENT 'Data de diagnóstico/início',
  `end_date` DATE NULL COMMENT 'Data de fim. NULL se a condição ainda estiver ativa.',
  
  PRIMARY KEY (`id`),
  KEY `fk_condition_person_idx` (`person_id`),
  CONSTRAINT `fk_condition_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`)
);

-- Tabela de Sinais Vitais do Paciente (Input da IA)
CREATE TABLE `person_vitals` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `person_id` INT NOT NULL,
  `measurement_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `blood_pressure_systolic` INT NULL,
  `blood_pressure_diastolic` INT NULL,
  `heart_rate` INT NULL,
  `notes` TEXT NULL,
  
  PRIMARY KEY (`id`),
  KEY `fk_vitals_person_idx` (`person_id`),
  CONSTRAINT `fk_vitals_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`)
);

-- Tabela de Alertas (Output da IA)
CREATE TABLE `clinical_alert_log` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `person_id` INT NOT NULL,
  `doctor_id` INT NOT NULL,
  `prescription_item_id` INT NULL,
  
  `alert_type` ENUM('INTERACTION', 'ALLERGY', 'CONDITION') NOT NULL,
  `alert_severity` ENUM('mild', 'moderate', 'severe') NOT NULL,
  `alert_message` TEXT NOT NULL,
  
  `doctor_action` ENUM('ACKNOWLEDGED', 'OVERRIDDEN', 'PRESCRIPTION_CANCELLED') NULL,
  `doctor_justification` TEXT NULL,
  
  PRIMARY KEY (`id`),
  KEY `fk_alert_person_idx` (`person_id`),
  KEY `fk_alert_doctor_idx` (`doctor_id`),
  KEY `fk_alert_prescription_item_idx` (`prescription_item_id`),
  CONSTRAINT `fk_alert_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`),
  CONSTRAINT `fk_alert_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `account` (`id`),
  CONSTRAINT `fk_alert_prescription_item` FOREIGN KEY (`prescription_item_id`) REFERENCES `prescription_item` (`id`)
);