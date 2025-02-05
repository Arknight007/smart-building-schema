-- Core building information
CREATE TABLE buildings (
    building_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    location VARCHAR(200),
    total_floors INT,
    construction_year INT,
    last_renovation_date DATE
);

-- IoT devices and sensors
CREATE TABLE sensors (
    sensor_id INT PRIMARY KEY AUTO_INCREMENT,
    building_id INT,
    sensor_type ENUM('TEMPERATURE', 'HUMIDITY', 'PRESSURE', 'CO2', 'OCCUPANCY', 'ENERGY'),
    location VARCHAR(100),
    installation_date DATE,
    last_calibration_date DATE,
    maintenance_interval INT, -- in days
    FOREIGN KEY (building_id) REFERENCES buildings(building_id)
);

-- Real-time sensor readings
CREATE TABLE sensor_readings (
    reading_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    sensor_id INT,
    timestamp TIMESTAMP,
    value DECIMAL(10,2),
    unit VARCHAR(20),
    FOREIGN KEY (sensor_id) REFERENCES sensors(sensor_id)
);

-- HVAC system components
CREATE TABLE hvac_components (
    component_id INT PRIMARY KEY AUTO_INCREMENT,
    building_id INT,
    component_type ENUM('AHU', 'CHILLER', 'BOILER', 'VAV', 'PUMP'),
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    installation_date DATE,
    expected_lifetime INT, -- in years
    FOREIGN KEY (building_id) REFERENCES buildings(building_id)
);

-- Maintenance history
CREATE TABLE maintenance_records (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    component_id INT,
    maintenance_date DATE,
    maintenance_type ENUM('PREVENTIVE', 'CORRECTIVE', 'PREDICTIVE'),
    description TEXT,
    cost DECIMAL(10,2),
    technician VARCHAR(100),
    FOREIGN KEY (component_id) REFERENCES hvac_components(component_id)
);

-- Predictive maintenance alerts
CREATE TABLE maintenance_predictions (
    prediction_id INT PRIMARY KEY AUTO_INCREMENT,
    component_id INT,
    prediction_date DATE,
    probability_of_failure DECIMAL(5,2),
    recommended_action TEXT,
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'),
    FOREIGN KEY (component_id) REFERENCES hvac_components(component_id)
);

-- Energy consumption patterns
CREATE TABLE energy_consumption (
    consumption_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    building_id INT,
    timestamp TIMESTAMP,
    kwh_usage DECIMAL(10,2),
    cost_per_kwh DECIMAL(5,2),
    FOREIGN KEY (building_id) REFERENCES buildings(building_id)
);

-- Create indexes for better query performance
CREATE INDEX idx_sensor_readings_timestamp ON sensor_readings(timestamp);
CREATE INDEX idx_energy_consumption_timestamp ON energy_consumption(timestamp);
CREATE INDEX idx_maintenance_predictions_priority ON maintenance_predictions(priority);

-- Views for common analytics queries
CREATE VIEW vw_critical_maintenance AS
SELECT 
    b.name as building_name,
    hc.component_type,
    mp.prediction_date,
    mp.probability_of_failure,
    mp.recommended_action
FROM maintenance_predictions mp
JOIN hvac_components hc ON mp.component_id = hc.component_id
JOIN buildings b ON hc.building_id = b.building_id
WHERE mp.priority = 'CRITICAL';

CREATE VIEW vw_energy_efficiency AS
SELECT 
    b.name as building_name,
    DATE(ec.timestamp) as date,
    SUM(ec.kwh_usage) as total_usage,
    AVG(ec.kwh_usage) as avg_usage,
    SUM(ec.kwh_usage * ec.cost_per_kwh) as total_cost
FROM energy_consumption ec
JOIN buildings b ON ec.building_id = b.building_id
GROUP BY b.name, DATE(ec.timestamp);
