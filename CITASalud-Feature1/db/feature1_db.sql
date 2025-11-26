-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 21-11-2025 a las 23:36:52
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `feature1_db`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ausencias_profesionales`
--

CREATE TABLE `ausencias_profesionales` (
  `id_ausencia` int(11) NOT NULL,
  `id_profesional` int(11) NOT NULL,
  `id_tipo` int(11) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `citas`
--

CREATE TABLE `citas` (
  `id_cita` int(11) NOT NULL,
  `id_paciente` int(11) NOT NULL,
  `id_profesional` int(11) NOT NULL,
  `id_sede` int(11) NOT NULL,
  `id_especialidad` int(11) NOT NULL,
  `id_horario` int(11) NOT NULL,
  `id_estado` int(11) NOT NULL,
  `veces_modificada` tinyint(4) NOT NULL DEFAULT 0,
  `recordatorio_enviado` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `citas`
--

INSERT INTO `citas` (`id_cita`, `id_paciente`, `id_profesional`, `id_sede`, `id_especialidad`, `id_horario`, `id_estado`, `veces_modificada`, `recordatorio_enviado`) VALUES
(5, 3, 11, 12, 19, 18, 4, 0, 0),
(6, 10, 2, 1, 1, 15, 5, 0, 0),
(7, 10, 7, 8, 7, 17, 4, 0, 0),
(8, 8, 16, 17, 16, 53, 4, 0, 0),
(9, 8, 17, 18, 17, 346, 5, 0, 0),
(10, 10, 2, 1, 1, 20, 5, 0, 0),
(11, 10, 2, 1, 1, 229, 5, 0, 0),
(12, 10, 16, 17, 16, 54, 4, 0, 0),
(13, 10, 17, 18, 17, 344, 4, 0, 0),
(14, 8, 19, 20, 19, 364, 3, 0, 0),
(15, 8, 16, 17, 16, 340, 5, 0, 0),
(16, 9, 16, 17, 16, 338, 4, 0, 0),
(17, 9, 17, 18, 17, 343, 4, 0, 0),
(18, 9, 17, 18, 51, 348, 3, 0, 0),
(19, 10, 11, 12, 19, 21, 2, 1, 0),
(20, 10, 19, 20, 19, 366, 3, 0, 0),
(21, 8, 17, 18, 17, 349, 3, 0, 0),
(22, 10, 17, 18, 17, 350, 3, 0, 0),
(23, 10, 19, 20, 19, 364, 3, 0, 0),
(24, 3, 18, 19, 18, 356, 3, 0, 0),
(25, 9, 16, 17, 16, 342, 3, 0, 0),
(26, 9, 20, 21, 28, 374, 3, 0, 0),
(27, 8, 20, 21, 28, 374, 3, 0, 0),
(28, 10, 17, 18, 17, 348, 3, 0, 0),
(29, 10, 16, 17, 16, 337, 4, 0, 0),
(30, 8, 21, 22, 30, 906, 5, 0, 0),
(31, 8, 24, 25, 36, 1046, 3, 0, 0),
(32, 8, 24, 25, 36, 1037, 3, 1, 0),
(33, 7, 2, 1, 1, 1085, 5, 0, 0),
(34, 7, 21, 22, 30, 924, 5, 0, 0),
(35, 7, 21, 22, 30, 931, 3, 0, 0),
(36, 7, 2, 1, 1, 1086, 4, 0, 0),
(37, 8, 16, 17, 16, 794, 2, 1, 0),
(38, 8, 13, 14, 13, 718, 2, 1, 0),
(39, 8, 19, 20, 19, 859, 2, 1, 0),
(40, 10, 13, 14, 13, 722, 1, 0, 0),
(41, 3, 2, 1, 1, 441, 1, 0, 0),
(42, 3, 13, 14, 13, 730, 3, 0, 0),
(43, 8, 13, 14, 13, 723, 1, 0, 0),
(44, 8, 23, 24, 5, 989, 2, 1, 0),
(45, 8, 12, 13, 12, 686, 1, 0, 0),
(46, 7, 11, 12, 19, 682, 3, 0, 0),
(47, 3, 15, 16, 15, 774, 1, 0, 0),
(48, 8, 8, 9, 8, 594, 2, 1, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ciudades`
--

CREATE TABLE `ciudades` (
  `id_ciudad` int(11) NOT NULL,
  `nombre_ciudad` varchar(100) NOT NULL,
  `departamento` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ciudades`
--

INSERT INTO `ciudades` (`id_ciudad`, `nombre_ciudad`, `departamento`) VALUES
(1, 'Bogotá', 'Cundinamarca'),
(2, 'Medellín', 'Antioquia'),
(3, 'Cali', 'Valle del Cauca'),
(4, 'Barranquilla', 'Atlántico'),
(5, 'Cartagena', 'Bolívar'),
(6, 'Bucaramanga', 'Santander'),
(7, 'Pereira', 'Risaralda'),
(8, 'Manizales', 'Caldas'),
(9, 'Cúcuta', 'Norte de Santander'),
(10, 'Bello', 'Antioquia'),
(11, 'Itagüí', 'Antioquia'),
(12, 'Envigado', 'Antioquia'),
(13, 'Floridablanca', 'Santander'),
(14, 'Girón', 'Santander'),
(15, 'Soledad', 'Atlántico'),
(16, 'Malambo', 'Atlántico'),
(17, 'Soacha', 'Cundinamarca'),
(18, 'Madrid', 'Cundinamarca'),
(19, 'Zipaquirá', 'Cundinamarca'),
(20, 'Palmira', 'Valle del Cauca'),
(21, 'Tuluá', 'Valle del Cauca'),
(22, 'Dosquebradas', 'Risaralda'),
(23, 'Santa Rosa de Cabal', 'Risaralda'),
(24, 'Villavicencio', 'Meta'),
(25, 'Ibagué', 'Tolima'),
(26, 'Popayán', 'Cauca'),
(27, 'Tunja', 'Boyacá'),
(28, 'Pasto', 'Nariño'),
(29, 'Montería', 'Córdoba');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `especialidades`
--

CREATE TABLE `especialidades` (
  `id_especialidad` int(11) NOT NULL,
  `nombre_especialidad` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `especialidades`
--

INSERT INTO `especialidades` (`id_especialidad`, `nombre_especialidad`, `descripcion`) VALUES
(1, 'Cardiología', 'Especialidad médica que se ocupa del diagnóstico y tratamiento de las enfermedades del corazón y del sistema circulatorio.'),
(2, 'Pediatría', 'Especialidad médica que se encarga del estudio del crecimiento y desarrollo de los niños hasta la adolescencia, así como del diagnóstico y tratamiento de sus enfermedades.'),
(3, 'Dermatología', 'Rama de la medicina que se especializa en el estudio, diagnóstico y tratamiento de las enfermedades de la piel, cabello y uñas.'),
(4, 'Ginecología', 'Especialidad médica y quirúrgica que se encarga de la salud integral de la mujer, especialmente en el diagnóstico y tratamiento de las enfermedades del sistema reproductor femenino.'),
(5, 'Neurología', 'Especialidad de la medicina que estudia el sistema nervioso y las enfermedades relacionadas con el cerebro, la médula espinal y los nervios periféricos.'),
(6, 'Odontología', 'Ciencia de la salud que se encarga del diagnóstico, tratamiento y prevención de las enfermedades de los dientes, encías y la cavidad oral en general.'),
(7, 'Ortopedia', 'Especialidad que se dedica al diagnóstico, corrección y prevención de deformidades o trastornos del sistema musculoesquelético.'),
(8, 'Oftalmología', 'Especialidad médica que estudia y trata las enfermedades relacionadas con los ojos, la visión y las estructuras oculares.'),
(9, 'Urología', 'Especialidad médico-quirúrgica que se ocupa del diagnóstico y tratamiento de las enfermedades del sistema urinario en hombres y mujeres, y del sistema reproductor masculino.'),
(10, 'Psiquiatría', 'Rama de la medicina que se dedica al estudio, diagnóstico y tratamiento de los trastornos mentales, emocionales y del comportamiento.'),
(11, 'Medicina Interna', 'Especialidad clínica que aborda de manera integral las enfermedades que afectan a los órganos internos de los adultos, sin procedimientos quirúrgicos.'),
(12, 'Nutrición', 'Especialidad que estudia la relación entre la alimentación y la salud humana, enfocada en la prevención y tratamiento de enfermedades a través de la dieta.'),
(13, 'Fisioterapia', 'Especialidad de la salud que utiliza medios físicos para prevenir, tratar y rehabilitar a personas con dolencias o discapacidades físicas.'),
(14, 'Oncología', 'Especialidad de la medicina que se dedica al diagnóstico y tratamiento del cáncer.'),
(15, 'Radiología', 'Especialidad médica que utiliza imágenes (rayos X, resonancia, etc.) para diagnosticar y, en algunos casos, tratar enfermedades y lesiones.'),
(16, 'Anestesiología', 'Especialidad que se encarga de la atención y cuidado del paciente antes, durante y después de un procedimiento quirúrgico, controlando la anestesia y las funciones vitales.'),
(17, 'Cirugía General', 'Especialidad quirúrgica que se ocupa del diagnóstico y tratamiento de enfermedades a través de procedimientos operatorios, principalmente en el abdomen.'),
(18, 'Endocrinología', 'Especialidad que estudia las glándulas endocrinas, sus hormonas y las enfermedades asociadas, como la diabetes y los trastornos de la tiroides.'),
(19, 'Gastroenterología', 'Especialidad médica que se enfoca en el estudio y tratamiento de las enfermedades del sistema digestivo, incluyendo el esófago, estómago, intestinos, hígado y páncreas.'),
(20, 'Hematología', 'Rama de la medicina que estudia la sangre, los órganos hematopoyéticos y el tratamiento de sus enfermedades.'),
(21, 'Nefrología', 'Especialidad que se dedica al estudio de la estructura y función de los riñones, y al diagnóstico y tratamiento de sus enfermedades.'),
(22, 'Neumología', 'Especialidad médica que se encarga del estudio y tratamiento de las enfermedades del sistema respiratorio, incluyendo los pulmones y las vías aéreas.'),
(23, 'Reumatología', 'Especialidad que se ocupa de las enfermedades del tejido conectivo, articulaciones, músculos y huesos.'),
(24, 'Inmunología', 'Ciencia que estudia el sistema inmunitario y las enfermedades relacionadas con sus funciones, como las alergias y las enfermedades autoinmunes.'),
(25, 'Genética Médica', 'Especialidad que diagnostica, previene y gestiona trastornos genéticos o hereditarios en individuos y sus familias.'),
(26, 'Toxicología', 'Disciplina que estudia los efectos adversos de sustancias químicas sobre los organismos vivos.'),
(27, 'Geriatría', 'Especialidad médica que se encarga de la salud y el bienestar de los adultos mayores, abordando sus enfermedades y necesidades específicas.'),
(28, 'Medicina Familiar', 'Especialidad que proporciona atención integral y continua a los individuos y sus familias, considerando su contexto biológico, psicológico y social.'),
(29, 'Patología', 'Especialidad médica que diagnostica enfermedades mediante el análisis de tejidos, fluidos corporales y órganos.'),
(30, 'Alergología', 'Especialidad que diagnostica y trata las enfermedades alérgicas, incluyendo asma, rinitis y reacciones a alimentos o medicamentos.'),
(31, 'Otorrinolaringología', 'Especialidad médico-quirúrgica que se enfoca en el oído, la nariz, la garganta y las estructuras relacionadas en la cabeza y el cuello.'),
(32, 'Terapia Respiratoria', 'Profesión de la salud que se encarga de la prevención, diagnóstico, tratamiento y rehabilitación de enfermedades que afectan el sistema respiratorio.'),
(33, 'Medicina Nuclear', 'Especialidad que utiliza sustancias radioactivas para diagnosticar y tratar enfermedades.'),
(34, 'Dermopatología', 'Subespecialidad que combina la dermatología y la patología, enfocándose en el diagnóstico de enfermedades de la piel a nivel microscópico.'),
(35, 'Oftalmología Pediátrica', 'Subespecialidad de la oftalmología que se enfoca en el cuidado de los ojos y la visión en niños.'),
(36, 'Cardiología Intervencionista', 'Subespecialidad de la cardiología que utiliza cateterismo para diagnosticar y tratar enfermedades cardíacas.'),
(37, 'Cirugía Plástica', 'Especialidad quirúrgica que se dedica a la restauración, reconstrucción o alteración de la forma del cuerpo humano.'),
(38, 'Medicina Estética', 'Rama de la medicina que se enfoca en mejorar la apariencia física de las personas a través de procedimientos no invasivos o mínimamente invasivos.'),
(39, 'Acupuntura', 'Práctica de la medicina tradicional china que utiliza agujas finas para estimular puntos específicos del cuerpo con fines terapéuticos.'),
(40, 'Homeopatía', 'Sistema de medicina alternativa que utiliza dosis mínimas de sustancias naturales para estimular la capacidad de autocuración del cuerpo.'),
(41, 'Quiropráctica', 'Disciplina de la salud que se centra en el diagnóstico, tratamiento y prevención de trastornos del sistema musculoesquelético, especialmente de la columna vertebral.'),
(42, 'Osteopatía', 'Sistema de medicina alternativa que se basa en la idea de que el cuerpo tiene la capacidad de curarse a sí mismo, a través de la manipulación del sistema musculoesquelético.'),
(43, 'Podología', 'Especialidad que se dedica al estudio, diagnóstico y tratamiento de las enfermedades y afecciones del pie.'),
(44, 'Medicina del Deporte', 'Especialidad que se enfoca en el cuidado médico de atletas y personas activas, incluyendo la prevención y tratamiento de lesiones deportivas.'),
(45, 'Sexología', 'Disciplina que estudia la sexualidad humana y sus trastornos.'),
(46, 'Epidemiología', 'Rama de la medicina que estudia la distribución, frecuencia y determinantes de las enfermedades en las poblaciones.'),
(47, 'Medicina Forense', 'Especialidad médica que se encarga de investigar las causas y circunstancias de la muerte para propósitos legales.'),
(48, 'Infectología', 'Especialidad que se dedica al diagnóstico y tratamiento de enfermedades causadas por agentes infecciosos como bacterias, virus y hongos.'),
(49, 'Nefrología Pediátrica', 'Subespecialidad de la nefrología que se enfoca en el diagnóstico y tratamiento de enfermedades renales en niños.'),
(50, 'Medicina Crítica', 'Especialidad médica que se encarga del cuidado de pacientes con enfermedades graves y potencialmente mortales.'),
(51, 'Endoscopia', 'Procedimiento médico que utiliza un endoscopio para examinar el interior del cuerpo, especialmente el sistema digestivo o respiratorio.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estados_cita`
--

CREATE TABLE `estados_cita` (
  `id_estado` int(11) NOT NULL,
  `nombre_estado` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estados_cita`
--

INSERT INTO `estados_cita` (`id_estado`, `nombre_estado`) VALUES
(1, 'Agendada'),
(4, 'Asistida'),
(3, 'Cancelada'),
(2, 'Modificada'),
(5, 'Sin asistencia');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estados_profesional`
--

CREATE TABLE `estados_profesional` (
  `id_estado` int(11) NOT NULL,
  `nombre_estado` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estados_profesional`
--

INSERT INTO `estados_profesional` (`id_estado`, `nombre_estado`) VALUES
(1, 'Activo'),
(4, 'Inactivo'),
(3, 'Licencia Médica'),
(2, 'Vacaciones');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historiales_cita`
--

CREATE TABLE `historiales_cita` (
  `id_historial` int(11) NOT NULL,
  `id_cita` int(11) NOT NULL,
  `id_estado` int(11) NOT NULL,
  `fecha_cambio` timestamp NOT NULL DEFAULT current_timestamp(),
  `observacion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `historiales_cita`
--

INSERT INTO `historiales_cita` (`id_historial`, `id_cita`, `id_estado`, `fecha_cambio`, `observacion`) VALUES
(2, 5, 4, '2025-09-19 19:48:11', 'Cita asistida por el paciente.'),
(3, 6, 5, '2025-09-19 19:57:32', 'Cita sin asistencia por parte de el paciente.'),
(4, 7, 4, '2025-09-19 20:06:14', 'Cita asistida por el paciente.'),
(5, 8, 4, '2025-09-30 19:49:47', 'Cita asistida por el paciente.'),
(6, 9, 5, '2025-09-30 19:54:38', 'Cita sin asistencia por parte de el paciente.'),
(7, 10, 5, '2025-09-30 20:14:52', 'Cita sin asistencia por parte de el paciente.'),
(8, 11, 5, '2025-09-30 20:17:06', 'Cita sin asistencia por parte de el paciente.'),
(9, 12, 4, '2025-09-30 20:30:36', 'Cita asistida por el paciente.'),
(10, 13, 4, '2025-10-30 16:22:01', 'Cita asistida por el paciente.'),
(11, 14, 3, '2025-10-30 17:31:31', 'Cita cancelada por el paciente.'),
(12, 15, 5, '2025-10-30 17:31:45', 'Cita sin asistencia por parte de el paciente.'),
(13, 16, 4, '2025-10-30 17:38:10', 'Cita asistida por el paciente.'),
(14, 17, 4, '2025-10-30 17:38:21', 'Cita asistida por el paciente.'),
(15, 18, 3, '2025-10-30 22:12:00', 'Cita cancelada por el paciente'),
(16, 19, 2, '2025-10-30 17:50:53', 'Cita modificada por el paciente.'),
(17, 20, 3, '2025-10-30 17:56:37', 'Cita cancelada por el paciente.'),
(18, 21, 3, '2025-10-30 20:10:45', 'Cita cancelada por el paciente.'),
(19, 21, 3, '2025-10-30 20:44:16', 'Cita cancelada por el paciente. '),
(20, 22, 3, '2025-10-30 21:34:32', 'Cita cancelada por el paciente.'),
(21, 23, 3, '2025-10-30 21:37:38', 'Cita cancelada por el paciente.'),
(22, 24, 3, '2025-10-30 22:07:19', 'Cita cancelada por el paciente'),
(23, 25, 3, '2025-10-30 22:14:10', 'Cita cancelada por el paciente'),
(24, 26, 3, '2025-10-30 22:16:01', 'Cita cancelada por el paciente'),
(25, 27, 3, '2025-10-30 22:20:52', 'Cita cancelada por el paciente'),
(26, 28, 3, '2025-10-30 22:49:43', 'Cita cancelada por el paciente'),
(27, 29, 4, '2025-10-30 23:09:11', 'Cita asistida por el paciente.'),
(28, 30, 5, '2025-10-31 01:58:33', 'Cita sin asistencia por parte de el paciente.'),
(29, 31, 3, '2025-11-04 03:20:11', 'Cita cancelada por el paciente'),
(30, 32, 3, '2025-11-04 03:32:37', 'Cita cancelada por el paciente'),
(31, 33, 5, '2025-11-02 17:30:20', 'Cita sin asistencia por parte de el paciente.'),
(32, 34, 5, '2025-11-02 17:35:01', 'Cita sin asistencia por parte de el paciente.'),
(33, 35, 3, '2025-11-02 17:56:17', 'Cita cancelada por el paciente'),
(34, 36, 4, '2025-11-02 17:45:37', 'Cita asistida por el paciente.'),
(35, 32, 3, '2025-11-04 03:32:37', 'Cita cancelada por el paciente'),
(36, 37, 1, '2025-11-04 03:40:36', 'Cita agendada por el paciente.'),
(37, 37, 2, '2025-11-04 16:56:07', 'Cita modificada por el paciente.'),
(38, 38, 1, '2025-11-04 17:06:06', 'Cita agendada por el paciente.'),
(39, 38, 2, '2025-11-04 17:08:17', 'Cita modificada por el paciente.'),
(40, 39, 1, '2025-11-04 17:14:30', 'Cita agendada por el paciente.'),
(41, 39, 2, '2025-11-04 17:14:56', 'Cita modificada por el paciente.'),
(42, 40, 1, '2025-11-04 18:45:01', 'Cita agendada por el paciente.'),
(43, 41, 1, '2025-11-04 20:49:07', 'Cita agendada por el paciente.'),
(44, 42, 3, '2025-11-04 22:14:26', 'Cita cancelada por el paciente'),
(45, 43, 1, '2025-11-04 22:11:40', 'Cita agendada por el paciente.'),
(46, 44, 1, '2025-11-04 22:12:08', 'Cita agendada por el paciente.'),
(47, 45, 1, '2025-11-04 22:12:37', 'Cita agendada por el paciente.'),
(48, 44, 2, '2025-11-04 22:13:22', 'Cita modificada por el paciente.'),
(49, 46, 3, '2025-11-04 22:20:14', 'Cita cancelada por el paciente'),
(50, 47, 1, '2025-11-04 22:21:42', 'Cita agendada por el paciente.'),
(51, 48, 1, '2025-11-05 01:18:10', 'Cita agendada por el paciente.'),
(52, 48, 2, '2025-11-05 01:18:31', 'Cita modificada por el paciente.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_cancelaciones`
--

CREATE TABLE `historial_cancelaciones` (
  `id_cancelacion` int(11) NOT NULL,
  `id_cita` int(11) NOT NULL,
  `id_paciente` int(11) NOT NULL,
  `id_motivo` int(11) NOT NULL,
  `fecha_cancelacion` date NOT NULL,
  `hora_cancelacion` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `historial_cancelaciones`
--

INSERT INTO `historial_cancelaciones` (`id_cancelacion`, `id_cita`, `id_paciente`, `id_motivo`, `fecha_cancelacion`, `hora_cancelacion`) VALUES
(1, 20, 10, 7, '2025-10-30', '12:56:48'),
(2, 14, 8, 8, '2025-10-30', '12:58:27'),
(3, 21, 8, 3, '2025-10-30', '15:44:16'),
(6, 24, 3, 6, '2025-10-30', '17:07:19'),
(7, 18, 9, 2, '2025-10-30', '17:12:00'),
(8, 25, 9, 1, '2025-10-30', '17:14:10'),
(9, 26, 9, 2, '2025-10-30', '17:16:01'),
(10, 27, 8, 5, '2025-10-30', '17:20:52'),
(11, 28, 10, 1, '2025-10-30', '17:49:43'),
(12, 35, 7, 3, '2025-11-02', '12:56:17'),
(13, 31, 8, 7, '2025-11-03', '22:20:11'),
(14, 32, 8, 7, '2025-11-03', '22:32:37'),
(15, 42, 3, 3, '2025-11-04', '17:14:26'),
(16, 46, 7, 3, '2025-11-04', '17:20:14');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_modificaciones`
--

CREATE TABLE `historial_modificaciones` (
  `id_modificacion` int(11) NOT NULL,
  `id_cita` int(11) NOT NULL,
  `fecha_anterior` date NOT NULL,
  `hora_anterior` time NOT NULL,
  `id_profesional_anterior` int(11) NOT NULL,
  `id_sede_anterior` int(11) NOT NULL,
  `fecha_nueva` date NOT NULL,
  `hora_nueva` time NOT NULL,
  `id_profesional_nuevo` int(11) NOT NULL,
  `id_sede_nueva` int(11) NOT NULL,
  `fecha_modificacion` date NOT NULL,
  `hora_modificacion` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `historial_modificaciones`
--

INSERT INTO `historial_modificaciones` (`id_modificacion`, `id_cita`, `fecha_anterior`, `hora_anterior`, `id_profesional_anterior`, `id_sede_anterior`, `fecha_nueva`, `hora_nueva`, `id_profesional_nuevo`, `id_sede_nueva`, `fecha_modificacion`, `hora_modificacion`) VALUES
(1, 32, '2025-11-13', '10:30:00', 24, 25, '2025-11-20', '10:00:00', 24, 25, '2025-11-03', '22:18:08'),
(2, 37, '2025-11-26', '15:30:00', 16, 17, '2025-11-25', '08:30:00', 16, 17, '2025-11-04', '11:56:07'),
(3, 38, '2025-11-17', '08:30:00', 13, 14, '2025-11-18', '14:30:00', 13, 14, '2025-11-04', '12:08:17'),
(4, 39, '2025-11-17', '08:00:00', 11, 12, '2025-11-24', '09:00:00', 19, 20, '2025-11-04', '12:14:56'),
(5, 44, '2025-11-26', '08:30:00', 23, 24, '2025-11-12', '08:00:00', 23, 24, '2025-11-04', '17:13:22'),
(6, 48, '2025-11-10', '08:00:00', 8, 9, '2025-11-11', '14:30:00', 8, 9, '2025-11-04', '20:18:31');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `horarios_profesionales`
--

CREATE TABLE `horarios_profesionales` (
  `id_horario` int(11) NOT NULL,
  `id_profesional` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `disponible` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `horarios_profesionales`
--

INSERT INTO `horarios_profesionales` (`id_horario`, `id_profesional`, `fecha`, `hora`, `disponible`) VALUES
(1, 2, '2025-09-17', '08:00:00', 1),
(2, 2, '2025-09-17', '08:30:00', 1),
(3, 2, '2025-09-17', '09:00:00', 1),
(4, 4, '2025-09-17', '10:00:00', 1),
(5, 4, '2025-09-17', '10:30:00', 1),
(6, 7, '2025-09-17', '11:00:00', 1),
(7, 7, '2025-09-17', '11:30:00', 1),
(8, 7, '2025-09-17', '12:00:00', 1),
(9, 11, '2025-09-18', '14:00:00', 1),
(10, 11, '2025-09-18', '14:30:00', 1),
(11, 11, '2025-09-18', '15:00:00', 1),
(12, 11, '2025-09-18', '15:30:00', 1),
(13, 19, '2025-09-18', '15:30:00', 1),
(14, 19, '2025-09-18', '17:30:00', 1),
(15, 2, '2025-09-19', '08:00:00', 0),
(16, 4, '2025-09-19', '10:30:00', 1),
(17, 7, '2025-09-26', '11:00:00', 0),
(18, 11, '2025-09-27', '15:00:00', 0),
(20, 2, '2025-10-24', '09:00:00', 0),
(21, 11, '2025-12-18', '10:00:00', 0),
(22, 19, '2026-02-16', '14:30:00', 1),
(23, 13, '2025-10-02', '08:00:00', 1),
(24, 13, '2025-10-02', '08:30:00', 1),
(25, 13, '2025-10-03', '09:00:00', 1),
(26, 13, '2025-10-03', '09:30:00', 1),
(27, 13, '2025-10-04', '10:00:00', 1),
(28, 13, '2025-10-04', '10:30:00', 1),
(29, 13, '2025-10-05', '11:00:00', 1),
(30, 13, '2025-10-05', '11:30:00', 1),
(31, 14, '2025-10-02', '12:00:00', 1),
(32, 14, '2025-10-02', '12:30:00', 1),
(33, 14, '2025-10-03', '13:00:00', 1),
(34, 14, '2025-10-03', '13:30:00', 1),
(35, 14, '2025-10-04', '14:00:00', 1),
(36, 14, '2025-10-04', '14:30:00', 1),
(37, 14, '2025-10-05', '15:00:00', 1),
(38, 14, '2025-10-05', '15:30:00', 1),
(39, 15, '2025-10-02', '16:00:00', 1),
(40, 15, '2025-10-02', '16:30:00', 1),
(41, 15, '2025-10-03', '17:00:00', 1),
(42, 15, '2025-10-03', '17:30:00', 1),
(43, 15, '2025-10-04', '18:00:00', 1),
(44, 15, '2025-10-04', '18:30:00', 1),
(45, 15, '2025-10-05', '19:00:00', 1),
(46, 15, '2025-10-05', '19:30:00', 1),
(47, 16, '2025-10-06', '07:00:00', 1),
(48, 16, '2025-10-06', '07:30:00', 1),
(49, 16, '2025-10-07', '08:00:00', 1),
(50, 16, '2025-10-07', '08:30:00', 1),
(51, 16, '2025-10-08', '09:00:00', 1),
(52, 16, '2025-10-08', '09:30:00', 1),
(53, 16, '2025-10-09', '10:00:00', 0),
(54, 16, '2025-10-09', '10:30:00', 0),
(55, 17, '2025-10-06', '11:00:00', 1),
(56, 17, '2025-10-06', '11:30:00', 1),
(57, 17, '2025-10-07', '12:00:00', 1),
(58, 17, '2025-10-07', '12:30:00', 1),
(59, 17, '2025-10-08', '13:00:00', 1),
(60, 17, '2025-10-08', '13:30:00', 1),
(61, 17, '2025-10-09', '14:00:00', 1),
(62, 17, '2025-10-09', '14:30:00', 1),
(63, 18, '2025-10-06', '15:00:00', 1),
(64, 18, '2025-10-06', '15:30:00', 1),
(65, 18, '2025-10-07', '16:00:00', 1),
(66, 18, '2025-10-07', '16:30:00', 1),
(67, 18, '2025-10-08', '17:00:00', 1),
(68, 18, '2025-10-08', '17:30:00', 1),
(69, 18, '2025-10-09', '18:00:00', 1),
(70, 18, '2025-10-09', '18:30:00', 1),
(71, 19, '2025-10-10', '07:00:00', 1),
(72, 19, '2025-10-10', '07:30:00', 1),
(73, 19, '2025-10-11', '08:00:00', 1),
(74, 19, '2025-10-11', '08:30:00', 1),
(75, 19, '2025-10-12', '09:00:00', 1),
(76, 19, '2025-10-12', '09:30:00', 1),
(77, 19, '2025-10-13', '10:00:00', 1),
(78, 19, '2025-10-13', '10:30:00', 1),
(79, 20, '2025-10-10', '11:00:00', 1),
(80, 20, '2025-10-10', '11:30:00', 1),
(81, 20, '2025-10-11', '12:00:00', 1),
(82, 20, '2025-10-11', '12:30:00', 1),
(83, 20, '2025-10-12', '13:00:00', 1),
(84, 20, '2025-10-12', '13:30:00', 1),
(85, 20, '2025-10-13', '14:00:00', 1),
(86, 20, '2025-10-13', '14:30:00', 1),
(215, 1, '2025-10-14', '07:00:00', 1),
(216, 1, '2025-10-14', '07:15:00', 1),
(217, 1, '2025-10-15', '07:45:00', 1),
(218, 1, '2025-10-15', '08:15:00', 1),
(219, 1, '2025-10-16', '08:45:00', 1),
(220, 1, '2025-10-16', '09:15:00', 1),
(221, 1, '2025-10-17', '09:45:00', 1),
(222, 1, '2025-10-17', '10:15:00', 1),
(223, 2, '2025-10-14', '10:45:00', 1),
(224, 2, '2025-10-14', '11:15:00', 1),
(225, 2, '2025-10-15', '11:45:00', 1),
(226, 2, '2025-10-15', '12:15:00', 1),
(227, 2, '2025-10-16', '12:45:00', 1),
(228, 2, '2025-10-16', '13:15:00', 1),
(229, 2, '2025-10-17', '13:45:00', 0),
(230, 2, '2025-10-17', '14:15:00', 1),
(231, 3, '2025-10-14', '14:45:00', 1),
(232, 3, '2025-10-14', '15:15:00', 1),
(233, 3, '2025-10-15', '15:45:00', 1),
(234, 3, '2025-10-15', '16:15:00', 1),
(235, 3, '2025-10-16', '16:45:00', 1),
(236, 3, '2025-10-16', '17:15:00', 1),
(237, 3, '2025-10-17', '17:45:00', 1),
(238, 3, '2025-10-17', '18:15:00', 1),
(239, 4, '2025-10-14', '18:45:00', 1),
(240, 4, '2025-10-14', '19:15:00', 1),
(241, 4, '2025-10-15', '19:45:00', 1),
(242, 4, '2025-10-15', '20:15:00', 1),
(243, 4, '2025-10-18', '07:00:00', 1),
(244, 4, '2025-10-18', '07:30:00', 1),
(245, 4, '2025-10-19', '08:00:00', 1),
(246, 4, '2025-10-19', '08:30:00', 1),
(247, 5, '2025-10-18', '09:00:00', 1),
(248, 5, '2025-10-18', '09:30:00', 1),
(249, 5, '2025-10-19', '10:00:00', 1),
(250, 5, '2025-10-19', '10:30:00', 1),
(251, 5, '2025-10-20', '11:00:00', 1),
(252, 5, '2025-10-20', '11:30:00', 1),
(253, 5, '2025-10-21', '12:00:00', 1),
(254, 5, '2025-10-21', '12:30:00', 1),
(255, 6, '2025-10-18', '13:00:00', 1),
(256, 6, '2025-10-18', '13:30:00', 1),
(257, 6, '2025-10-19', '14:00:00', 1),
(258, 6, '2025-10-19', '14:30:00', 1),
(259, 6, '2025-10-20', '15:00:00', 1),
(260, 6, '2025-10-20', '15:30:00', 1),
(261, 6, '2025-10-21', '16:00:00', 1),
(262, 6, '2025-10-21', '16:30:00', 1),
(263, 7, '2025-10-18', '17:00:00', 1),
(264, 7, '2025-10-18', '17:30:00', 1),
(265, 7, '2025-10-19', '18:00:00', 1),
(266, 7, '2025-10-19', '18:30:00', 1),
(267, 7, '2025-10-20', '19:00:00', 1),
(268, 7, '2025-10-20', '19:30:00', 1),
(269, 7, '2025-10-21', '20:00:00', 1),
(270, 7, '2025-10-21', '20:30:00', 1),
(271, 8, '2025-10-22', '06:30:00', 1),
(272, 8, '2025-10-22', '07:00:00', 1),
(273, 8, '2025-10-23', '07:30:00', 1),
(274, 8, '2025-10-23', '08:00:00', 1),
(275, 8, '2025-10-24', '08:30:00', 1),
(276, 8, '2025-10-24', '09:00:00', 1),
(277, 8, '2025-10-25', '09:30:00', 1),
(278, 8, '2025-10-25', '10:00:00', 1),
(279, 9, '2025-10-22', '10:30:00', 1),
(280, 9, '2025-10-22', '11:00:00', 1),
(281, 9, '2025-10-23', '11:30:00', 1),
(282, 9, '2025-10-23', '12:00:00', 1),
(283, 9, '2025-10-24', '12:30:00', 1),
(284, 9, '2025-10-24', '13:00:00', 1),
(285, 9, '2025-10-25', '13:30:00', 1),
(286, 9, '2025-10-25', '14:00:00', 1),
(287, 10, '2025-10-22', '14:30:00', 1),
(288, 10, '2025-10-22', '15:00:00', 1),
(289, 10, '2025-10-23', '15:30:00', 1),
(290, 10, '2025-10-23', '16:00:00', 1),
(291, 10, '2025-10-24', '16:30:00', 1),
(292, 10, '2025-10-24', '17:00:00', 1),
(293, 10, '2025-10-25', '17:30:00', 1),
(294, 10, '2025-10-25', '18:00:00', 1),
(295, 11, '2025-10-22', '18:30:00', 1),
(296, 11, '2025-10-22', '19:00:00', 1),
(297, 11, '2025-10-23', '19:30:00', 1),
(298, 11, '2025-10-23', '20:00:00', 1),
(299, 11, '2025-10-26', '06:00:00', 1),
(300, 11, '2025-10-26', '06:30:00', 1),
(301, 11, '2025-10-27', '07:00:00', 1),
(302, 11, '2025-10-27', '07:30:00', 1),
(303, 12, '2025-10-26', '08:00:00', 1),
(304, 12, '2025-10-26', '08:30:00', 1),
(305, 12, '2025-10-27', '09:00:00', 1),
(306, 12, '2025-10-27', '09:30:00', 1),
(307, 12, '2025-10-28', '10:00:00', 1),
(308, 12, '2025-10-28', '10:30:00', 1),
(309, 12, '2025-10-29', '11:00:00', 1),
(310, 12, '2025-10-29', '11:30:00', 1),
(311, 13, '2025-10-26', '12:00:00', 1),
(312, 13, '2025-10-26', '12:30:00', 1),
(313, 13, '2025-10-27', '13:00:00', 1),
(314, 13, '2025-10-27', '13:30:00', 1),
(315, 13, '2025-10-28', '14:00:00', 1),
(316, 13, '2025-10-28', '14:30:00', 1),
(317, 13, '2025-10-29', '15:00:00', 1),
(318, 13, '2025-10-29', '15:30:00', 1),
(319, 14, '2025-10-26', '16:00:00', 1),
(320, 14, '2025-10-26', '16:30:00', 1),
(321, 14, '2025-10-27', '17:00:00', 1),
(322, 14, '2025-10-27', '17:30:00', 1),
(323, 14, '2025-10-28', '18:00:00', 1),
(324, 14, '2025-10-28', '18:30:00', 1),
(325, 14, '2025-10-29', '19:00:00', 1),
(326, 14, '2025-10-29', '19:30:00', 1),
(327, 15, '2025-10-26', '20:00:00', 1),
(328, 15, '2025-10-26', '20:30:00', 1),
(329, 15, '2025-10-30', '06:15:00', 1),
(330, 15, '2025-10-30', '06:45:00', 1),
(331, 15, '2025-10-31', '07:15:00', 1),
(332, 15, '2025-10-31', '07:45:00', 1),
(333, 15, '2025-11-01', '08:15:00', 1),
(334, 15, '2025-11-01', '08:45:00', 1),
(335, 16, '2025-10-30', '09:15:00', 1),
(336, 16, '2025-10-30', '09:45:00', 1),
(337, 16, '2025-10-31', '10:15:00', 0),
(338, 16, '2025-10-31', '10:45:00', 0),
(339, 16, '2025-11-01', '11:15:00', 1),
(340, 16, '2025-11-01', '11:45:00', 0),
(341, 16, '2025-11-02', '12:15:00', 1),
(342, 16, '2025-11-02', '12:45:00', 1),
(343, 17, '2025-10-30', '13:15:00', 0),
(344, 17, '2025-10-30', '13:45:00', 0),
(345, 17, '2025-10-31', '14:15:00', 1),
(346, 17, '2025-10-31', '14:45:00', 0),
(347, 17, '2025-11-01', '15:15:00', 1),
(348, 17, '2025-11-01', '15:45:00', 1),
(349, 17, '2025-11-02', '16:15:00', 1),
(350, 17, '2025-11-02', '16:45:00', 1),
(351, 18, '2025-10-30', '17:15:00', 1),
(352, 18, '2025-10-30', '17:45:00', 1),
(353, 18, '2025-10-31', '18:15:00', 1),
(354, 18, '2025-10-31', '18:45:00', 1),
(355, 18, '2025-11-01', '19:15:00', 1),
(356, 18, '2025-11-01', '19:45:00', 1),
(357, 18, '2025-11-02', '20:15:00', 1),
(358, 18, '2025-11-02', '20:45:00', 1),
(359, 19, '2025-11-03', '06:00:00', 1),
(360, 19, '2025-11-03', '06:30:00', 1),
(361, 19, '2025-11-04', '07:00:00', 1),
(362, 19, '2025-11-04', '07:30:00', 1),
(363, 19, '2025-11-05', '08:00:00', 1),
(364, 19, '2025-11-05', '08:30:00', 1),
(365, 19, '2025-11-06', '09:00:00', 1),
(366, 19, '2025-11-06', '09:30:00', 1),
(367, 20, '2025-11-03', '10:00:00', 1),
(368, 20, '2025-11-03', '10:30:00', 1),
(369, 20, '2025-11-04', '11:00:00', 1),
(370, 20, '2025-11-04', '11:30:00', 1),
(371, 20, '2025-11-05', '12:00:00', 1),
(372, 20, '2025-11-05', '12:30:00', 1),
(373, 20, '2025-11-06', '13:00:00', 1),
(374, 20, '2025-11-06', '13:30:00', 1),
(375, 1, '2025-11-03', '08:00:00', 1),
(376, 1, '2025-11-03', '08:30:00', 1),
(377, 1, '2025-11-03', '09:00:00', 1),
(378, 1, '2025-11-03', '09:30:00', 1),
(379, 1, '2025-11-03', '10:00:00', 1),
(380, 1, '2025-11-03', '10:30:00', 1),
(381, 1, '2025-11-03', '11:00:00', 1),
(382, 1, '2025-11-03', '11:30:00', 1),
(383, 1, '2025-11-03', '14:00:00', 1),
(384, 1, '2025-11-03', '14:30:00', 1),
(385, 1, '2025-11-03', '15:00:00', 1),
(386, 1, '2025-11-03', '15:30:00', 1),
(387, 1, '2025-11-03', '16:00:00', 1),
(388, 1, '2025-11-03', '16:30:00', 1),
(389, 1, '2025-11-03', '17:00:00', 1),
(390, 1, '2025-11-04', '08:00:00', 1),
(391, 1, '2025-11-04', '08:30:00', 1),
(392, 1, '2025-11-04', '09:00:00', 1),
(393, 1, '2025-11-04', '09:30:00', 1),
(394, 1, '2025-11-04', '10:00:00', 1),
(395, 1, '2025-11-04', '10:30:00', 1),
(396, 1, '2025-11-04', '11:00:00', 1),
(397, 1, '2025-11-04', '11:30:00', 1),
(398, 1, '2025-11-04', '14:00:00', 1),
(399, 1, '2025-11-04', '14:30:00', 1),
(400, 1, '2025-11-04', '15:00:00', 1),
(401, 1, '2025-11-04', '15:30:00', 1),
(402, 1, '2025-11-05', '08:00:00', 1),
(403, 1, '2025-11-05', '08:30:00', 1),
(404, 1, '2025-11-05', '09:00:00', 1),
(405, 1, '2025-11-05', '09:30:00', 1),
(406, 1, '2025-11-05', '10:00:00', 1),
(407, 1, '2025-11-05', '10:30:00', 1),
(408, 1, '2025-11-05', '11:00:00', 1),
(409, 1, '2025-11-05', '11:30:00', 1),
(410, 1, '2025-11-06', '08:00:00', 1),
(411, 1, '2025-11-06', '09:00:00', 1),
(412, 1, '2025-11-06', '10:00:00', 1),
(413, 1, '2025-11-06', '11:00:00', 1),
(414, 2, '2025-11-03', '08:00:00', 1),
(415, 2, '2025-11-03', '08:30:00', 1),
(416, 2, '2025-11-03', '09:00:00', 1),
(417, 2, '2025-11-03', '09:30:00', 1),
(418, 2, '2025-11-03', '10:00:00', 1),
(419, 2, '2025-11-03', '10:30:00', 1),
(420, 2, '2025-11-03', '11:00:00', 1),
(421, 2, '2025-11-03', '11:30:00', 1),
(422, 2, '2025-11-03', '14:00:00', 1),
(423, 2, '2025-11-03', '14:30:00', 1),
(424, 2, '2025-11-03', '15:00:00', 1),
(425, 2, '2025-11-03', '15:30:00', 1),
(426, 2, '2025-11-03', '16:00:00', 1),
(427, 2, '2025-11-03', '16:30:00', 1),
(428, 2, '2025-11-03', '17:00:00', 1),
(429, 2, '2025-11-04', '08:00:00', 1),
(430, 2, '2025-11-04', '08:30:00', 1),
(431, 2, '2025-11-04', '09:00:00', 1),
(432, 2, '2025-11-04', '09:30:00', 1),
(433, 2, '2025-11-04', '10:00:00', 1),
(434, 2, '2025-11-04', '10:30:00', 1),
(435, 2, '2025-11-04', '11:00:00', 1),
(436, 2, '2025-11-04', '11:30:00', 1),
(437, 2, '2025-11-04', '14:00:00', 1),
(438, 2, '2025-11-04', '14:30:00', 1),
(439, 2, '2025-11-04', '15:00:00', 1),
(440, 2, '2025-11-04', '15:30:00', 1),
(441, 2, '2025-11-05', '08:00:00', 0),
(442, 2, '2025-11-05', '08:30:00', 1),
(443, 2, '2025-11-05', '09:00:00', 1),
(444, 2, '2025-11-05', '09:30:00', 1),
(445, 2, '2025-11-05', '10:00:00', 1),
(446, 2, '2025-11-05', '10:30:00', 1),
(447, 2, '2025-11-05', '11:00:00', 1),
(448, 2, '2025-11-05', '11:30:00', 1),
(449, 2, '2025-11-06', '08:00:00', 1),
(450, 2, '2025-11-06', '09:00:00', 1),
(451, 2, '2025-11-06', '10:00:00', 1),
(452, 2, '2025-11-06', '11:00:00', 1),
(453, 3, '2025-11-03', '08:00:00', 1),
(454, 3, '2025-11-03', '08:30:00', 1),
(455, 3, '2025-11-03', '09:00:00', 1),
(456, 3, '2025-11-03', '09:30:00', 1),
(457, 3, '2025-11-03', '10:00:00', 1),
(458, 3, '2025-11-03', '10:30:00', 1),
(459, 3, '2025-11-03', '11:00:00', 1),
(460, 3, '2025-11-03', '11:30:00', 1),
(461, 3, '2025-11-03', '14:00:00', 1),
(462, 3, '2025-11-03', '14:30:00', 1),
(463, 3, '2025-11-03', '15:00:00', 1),
(464, 3, '2025-11-03', '15:30:00', 1),
(465, 3, '2025-11-04', '08:00:00', 1),
(466, 3, '2025-11-04', '08:30:00', 1),
(467, 3, '2025-11-04', '09:00:00', 1),
(468, 3, '2025-11-04', '09:30:00', 1),
(469, 3, '2025-11-04', '10:00:00', 1),
(470, 3, '2025-11-04', '10:30:00', 1),
(471, 3, '2025-11-04', '11:00:00', 1),
(472, 3, '2025-11-04', '11:30:00', 1),
(473, 3, '2025-11-05', '14:00:00', 1),
(474, 3, '2025-11-05', '14:30:00', 1),
(475, 3, '2025-11-05', '15:00:00', 1),
(476, 3, '2025-11-05', '15:30:00', 1),
(477, 3, '2025-11-06', '08:00:00', 1),
(478, 3, '2025-11-06', '09:00:00', 1),
(479, 3, '2025-11-06', '10:00:00', 1),
(480, 3, '2025-11-06', '11:00:00', 1),
(481, 4, '2025-11-03', '08:00:00', 1),
(482, 4, '2025-11-03', '08:30:00', 1),
(483, 4, '2025-11-03', '09:00:00', 1),
(484, 4, '2025-11-03', '09:30:00', 1),
(485, 4, '2025-11-03', '10:00:00', 1),
(486, 4, '2025-11-03', '10:30:00', 1),
(487, 4, '2025-11-03', '11:00:00', 1),
(488, 4, '2025-11-03', '11:30:00', 1),
(489, 4, '2025-11-03', '14:00:00', 1),
(490, 4, '2025-11-03', '14:30:00', 1),
(491, 4, '2025-11-03', '15:00:00', 1),
(492, 4, '2025-11-03', '15:30:00', 1),
(493, 4, '2025-11-04', '08:00:00', 1),
(494, 4, '2025-11-04', '08:30:00', 1),
(495, 4, '2025-11-04', '09:00:00', 1),
(496, 4, '2025-11-04', '09:30:00', 1),
(497, 4, '2025-11-04', '10:00:00', 1),
(498, 4, '2025-11-04', '10:30:00', 1),
(499, 4, '2025-11-04', '11:00:00', 1),
(500, 4, '2025-11-04', '11:30:00', 1),
(501, 4, '2025-11-05', '08:00:00', 1),
(502, 4, '2025-11-05', '08:30:00', 1),
(503, 4, '2025-11-05', '09:00:00', 1),
(504, 4, '2025-11-05', '09:30:00', 1),
(505, 4, '2025-11-06', '14:00:00', 1),
(506, 4, '2025-11-06', '14:30:00', 1),
(507, 4, '2025-11-06', '15:00:00', 1),
(508, 4, '2025-11-06', '15:30:00', 1),
(509, 5, '2025-11-03', '08:00:00', 1),
(510, 5, '2025-11-03', '08:30:00', 1),
(511, 5, '2025-11-03', '09:00:00', 1),
(512, 5, '2025-11-03', '09:30:00', 1),
(513, 5, '2025-11-03', '10:00:00', 1),
(514, 5, '2025-11-03', '10:30:00', 1),
(515, 5, '2025-11-03', '11:00:00', 1),
(516, 5, '2025-11-03', '11:30:00', 1),
(517, 5, '2025-11-04', '08:00:00', 1),
(518, 5, '2025-11-04', '08:30:00', 1),
(519, 5, '2025-11-04', '09:00:00', 1),
(520, 5, '2025-11-04', '09:30:00', 1),
(521, 5, '2025-11-04', '10:00:00', 1),
(522, 5, '2025-11-04', '10:30:00', 1),
(523, 5, '2025-11-04', '11:00:00', 1),
(524, 5, '2025-11-04', '11:30:00', 1),
(525, 5, '2025-11-05', '14:00:00', 1),
(526, 5, '2025-11-05', '14:30:00', 1),
(527, 5, '2025-11-05', '15:00:00', 1),
(528, 5, '2025-11-05', '15:30:00', 1),
(529, 5, '2025-11-06', '08:00:00', 1),
(530, 5, '2025-11-06', '09:00:00', 1),
(531, 5, '2025-11-06', '10:00:00', 1),
(532, 5, '2025-11-06', '11:00:00', 1),
(533, 6, '2025-11-10', '08:00:00', 1),
(534, 6, '2025-11-10', '08:30:00', 1),
(535, 6, '2025-11-10', '09:00:00', 1),
(536, 6, '2025-11-10', '09:30:00', 1),
(537, 6, '2025-11-10', '10:00:00', 1),
(538, 6, '2025-11-10', '10:30:00', 1),
(539, 6, '2025-11-10', '11:00:00', 1),
(540, 6, '2025-11-10', '11:30:00', 1),
(541, 6, '2025-11-10', '14:00:00', 1),
(542, 6, '2025-11-10', '14:30:00', 1),
(543, 6, '2025-11-10', '15:00:00', 1),
(544, 6, '2025-11-10', '15:30:00', 1),
(545, 6, '2025-11-11', '08:00:00', 1),
(546, 6, '2025-11-11', '08:30:00', 1),
(547, 6, '2025-11-11', '09:00:00', 1),
(548, 6, '2025-11-11', '09:30:00', 1),
(549, 6, '2025-11-11', '10:00:00', 1),
(550, 6, '2025-11-11', '10:30:00', 1),
(551, 6, '2025-11-11', '11:00:00', 1),
(552, 6, '2025-11-11', '11:30:00', 1),
(553, 6, '2025-11-12', '14:00:00', 1),
(554, 6, '2025-11-12', '14:30:00', 1),
(555, 6, '2025-11-12', '15:00:00', 1),
(556, 6, '2025-11-12', '15:30:00', 1),
(557, 6, '2025-11-13', '08:00:00', 1),
(558, 6, '2025-11-13', '09:00:00', 1),
(559, 6, '2025-11-13', '10:00:00', 1),
(560, 6, '2025-11-13', '11:00:00', 1),
(561, 7, '2025-11-10', '08:00:00', 1),
(562, 7, '2025-11-10', '08:30:00', 1),
(563, 7, '2025-11-10', '09:00:00', 1),
(564, 7, '2025-11-10', '09:30:00', 1),
(565, 7, '2025-11-10', '10:00:00', 1),
(566, 7, '2025-11-10', '10:30:00', 1),
(567, 7, '2025-11-10', '11:00:00', 1),
(568, 7, '2025-11-10', '11:30:00', 1),
(569, 7, '2025-11-11', '08:00:00', 1),
(570, 7, '2025-11-11', '08:30:00', 1),
(571, 7, '2025-11-11', '09:00:00', 1),
(572, 7, '2025-11-11', '09:30:00', 1),
(573, 7, '2025-11-11', '10:00:00', 1),
(574, 7, '2025-11-11', '10:30:00', 1),
(575, 7, '2025-11-11', '11:00:00', 1),
(576, 7, '2025-11-11', '11:30:00', 1),
(577, 7, '2025-11-12', '14:00:00', 1),
(578, 7, '2025-11-12', '14:30:00', 1),
(579, 7, '2025-11-12', '15:00:00', 1),
(580, 7, '2025-11-12', '15:30:00', 1),
(581, 7, '2025-11-13', '08:00:00', 1),
(582, 7, '2025-11-13', '09:00:00', 1),
(583, 7, '2025-11-13', '10:00:00', 1),
(584, 7, '2025-11-13', '11:00:00', 1),
(585, 8, '2025-11-10', '08:00:00', 1),
(586, 8, '2025-11-10', '08:30:00', 1),
(587, 8, '2025-11-10', '09:00:00', 1),
(588, 8, '2025-11-10', '09:30:00', 1),
(589, 8, '2025-11-10', '10:00:00', 1),
(590, 8, '2025-11-10', '10:30:00', 1),
(591, 8, '2025-11-10', '11:00:00', 1),
(592, 8, '2025-11-10', '11:30:00', 1),
(593, 8, '2025-11-11', '14:00:00', 1),
(594, 8, '2025-11-11', '14:30:00', 0),
(595, 8, '2025-11-11', '15:00:00', 1),
(596, 8, '2025-11-11', '15:30:00', 1),
(597, 8, '2025-11-12', '08:00:00', 1),
(598, 8, '2025-11-12', '08:30:00', 1),
(599, 8, '2025-11-12', '09:00:00', 1),
(600, 8, '2025-11-12', '09:30:00', 1),
(601, 8, '2025-11-12', '10:00:00', 1),
(602, 8, '2025-11-12', '10:30:00', 1),
(603, 8, '2025-11-12', '11:00:00', 1),
(604, 8, '2025-11-12', '11:30:00', 1),
(605, 8, '2025-11-13', '08:00:00', 1),
(606, 8, '2025-11-13', '09:00:00', 1),
(607, 8, '2025-11-13', '10:00:00', 1),
(608, 8, '2025-11-13', '11:00:00', 1),
(609, 9, '2025-11-10', '08:00:00', 1),
(610, 9, '2025-11-10', '08:30:00', 1),
(611, 9, '2025-11-10', '09:00:00', 1),
(612, 9, '2025-11-10', '09:30:00', 1),
(613, 9, '2025-11-10', '10:00:00', 1),
(614, 9, '2025-11-10', '10:30:00', 1),
(615, 9, '2025-11-10', '11:00:00', 1),
(616, 9, '2025-11-10', '11:30:00', 1),
(617, 9, '2025-11-11', '08:00:00', 1),
(618, 9, '2025-11-11', '08:30:00', 1),
(619, 9, '2025-11-11', '09:00:00', 1),
(620, 9, '2025-11-11', '09:30:00', 1),
(621, 9, '2025-11-11', '10:00:00', 1),
(622, 9, '2025-11-11', '10:30:00', 1),
(623, 9, '2025-11-11', '11:00:00', 1),
(624, 9, '2025-11-11', '11:30:00', 1),
(625, 9, '2025-11-12', '14:00:00', 1),
(626, 9, '2025-11-12', '14:30:00', 1),
(627, 9, '2025-11-12', '15:00:00', 1),
(628, 9, '2025-11-12', '15:30:00', 1),
(629, 9, '2025-11-13', '08:00:00', 1),
(630, 9, '2025-11-13', '09:00:00', 1),
(631, 9, '2025-11-13', '10:00:00', 1),
(632, 9, '2025-11-13', '11:00:00', 1),
(633, 10, '2025-11-10', '08:00:00', 1),
(634, 10, '2025-11-10', '08:30:00', 1),
(635, 10, '2025-11-10', '09:00:00', 1),
(636, 10, '2025-11-10', '09:30:00', 1),
(637, 10, '2025-11-10', '10:00:00', 1),
(638, 10, '2025-11-10', '10:30:00', 1),
(639, 10, '2025-11-10', '11:00:00', 1),
(640, 10, '2025-11-10', '11:30:00', 1),
(641, 10, '2025-11-11', '08:00:00', 1),
(642, 10, '2025-11-11', '08:30:00', 1),
(643, 10, '2025-11-11', '09:00:00', 1),
(644, 10, '2025-11-11', '09:30:00', 1),
(645, 10, '2025-11-11', '10:00:00', 1),
(646, 10, '2025-11-11', '10:30:00', 1),
(647, 10, '2025-11-11', '11:00:00', 1),
(648, 10, '2025-11-11', '11:30:00', 1),
(649, 10, '2025-11-12', '14:00:00', 1),
(650, 10, '2025-11-12', '14:30:00', 1),
(651, 10, '2025-11-12', '15:00:00', 1),
(652, 10, '2025-11-12', '15:30:00', 1),
(653, 10, '2025-11-13', '08:00:00', 1),
(654, 10, '2025-11-13', '09:00:00', 1),
(655, 10, '2025-11-13', '10:00:00', 1),
(656, 10, '2025-11-13', '11:00:00', 1),
(657, 11, '2025-11-17', '08:00:00', 1),
(658, 11, '2025-11-17', '08:30:00', 1),
(659, 11, '2025-11-17', '09:00:00', 1),
(660, 11, '2025-11-17', '09:30:00', 1),
(661, 11, '2025-11-17', '10:00:00', 1),
(662, 11, '2025-11-17', '10:30:00', 1),
(663, 11, '2025-11-17', '11:00:00', 1),
(664, 11, '2025-11-17', '11:30:00', 1),
(665, 11, '2025-11-17', '14:00:00', 1),
(666, 11, '2025-11-17', '14:30:00', 1),
(667, 11, '2025-11-17', '15:00:00', 1),
(668, 11, '2025-11-17', '15:30:00', 1),
(669, 11, '2025-11-18', '08:00:00', 1),
(670, 11, '2025-11-18', '08:30:00', 1),
(671, 11, '2025-11-18', '09:00:00', 1),
(672, 11, '2025-11-18', '09:30:00', 1),
(673, 11, '2025-11-18', '10:00:00', 1),
(674, 11, '2025-11-18', '10:30:00', 1),
(675, 11, '2025-11-18', '11:00:00', 1),
(676, 11, '2025-11-18', '11:30:00', 1),
(677, 11, '2025-11-19', '14:00:00', 1),
(678, 11, '2025-11-19', '14:30:00', 1),
(679, 11, '2025-11-19', '15:00:00', 1),
(680, 11, '2025-11-19', '15:30:00', 1),
(681, 11, '2025-11-20', '08:00:00', 1),
(682, 11, '2025-11-20', '09:00:00', 1),
(683, 11, '2025-11-20', '10:00:00', 1),
(684, 11, '2025-11-20', '11:00:00', 1),
(685, 12, '2025-11-17', '08:00:00', 1),
(686, 12, '2025-11-17', '08:30:00', 0),
(687, 12, '2025-11-17', '09:00:00', 1),
(688, 12, '2025-11-17', '09:30:00', 1),
(689, 12, '2025-11-17', '10:00:00', 1),
(690, 12, '2025-11-17', '10:30:00', 1),
(691, 12, '2025-11-17', '11:00:00', 1),
(692, 12, '2025-11-17', '11:30:00', 1),
(693, 12, '2025-11-18', '08:00:00', 1),
(694, 12, '2025-11-18', '08:30:00', 1),
(695, 12, '2025-11-18', '09:00:00', 1),
(696, 12, '2025-11-18', '09:30:00', 1),
(697, 12, '2025-11-18', '10:00:00', 1),
(698, 12, '2025-11-18', '10:30:00', 1),
(699, 12, '2025-11-18', '11:00:00', 1),
(700, 12, '2025-11-18', '11:30:00', 1),
(701, 12, '2025-11-19', '14:00:00', 1),
(702, 12, '2025-11-19', '14:30:00', 1),
(703, 12, '2025-11-19', '15:00:00', 1),
(704, 12, '2025-11-19', '15:30:00', 1),
(705, 12, '2025-11-20', '08:00:00', 1),
(706, 12, '2025-11-20', '09:00:00', 1),
(707, 12, '2025-11-20', '10:00:00', 1),
(708, 12, '2025-11-20', '11:00:00', 1),
(709, 13, '2025-11-17', '08:00:00', 1),
(710, 13, '2025-11-17', '08:30:00', 1),
(711, 13, '2025-11-17', '09:00:00', 1),
(712, 13, '2025-11-17', '09:30:00', 1),
(713, 13, '2025-11-17', '10:00:00', 1),
(714, 13, '2025-11-17', '10:30:00', 1),
(715, 13, '2025-11-17', '11:00:00', 1),
(716, 13, '2025-11-17', '11:30:00', 1),
(717, 13, '2025-11-18', '14:00:00', 1),
(718, 13, '2025-11-18', '14:30:00', 0),
(719, 13, '2025-11-18', '15:00:00', 1),
(720, 13, '2025-11-18', '15:30:00', 1),
(721, 13, '2025-11-19', '08:00:00', 1),
(722, 13, '2025-11-19', '08:30:00', 0),
(723, 13, '2025-11-19', '09:00:00', 0),
(724, 13, '2025-11-19', '09:30:00', 1),
(725, 13, '2025-11-19', '10:00:00', 1),
(726, 13, '2025-11-19', '10:30:00', 1),
(727, 13, '2025-11-19', '11:00:00', 1),
(728, 13, '2025-11-19', '11:30:00', 1),
(729, 13, '2025-11-20', '08:00:00', 1),
(730, 13, '2025-11-20', '09:00:00', 1),
(731, 13, '2025-11-20', '10:00:00', 1),
(732, 13, '2025-11-20', '11:00:00', 1),
(733, 14, '2025-11-17', '08:00:00', 1),
(734, 14, '2025-11-17', '08:30:00', 1),
(735, 14, '2025-11-17', '09:00:00', 1),
(736, 14, '2025-11-17', '09:30:00', 1),
(737, 14, '2025-11-17', '10:00:00', 1),
(738, 14, '2025-11-17', '10:30:00', 1),
(739, 14, '2025-11-17', '11:00:00', 1),
(740, 14, '2025-11-17', '11:30:00', 1),
(741, 14, '2025-11-18', '08:00:00', 1),
(742, 14, '2025-11-18', '08:30:00', 1),
(743, 14, '2025-11-18', '09:00:00', 1),
(744, 14, '2025-11-18', '09:30:00', 1),
(745, 14, '2025-11-18', '10:00:00', 1),
(746, 14, '2025-11-18', '10:30:00', 1),
(747, 14, '2025-11-18', '11:00:00', 1),
(748, 14, '2025-11-18', '11:30:00', 1),
(749, 14, '2025-11-19', '14:00:00', 1),
(750, 14, '2025-11-19', '14:30:00', 1),
(751, 14, '2025-11-19', '15:00:00', 1),
(752, 14, '2025-11-19', '15:30:00', 1),
(753, 14, '2025-11-20', '08:00:00', 1),
(754, 14, '2025-11-20', '09:00:00', 1),
(755, 14, '2025-11-20', '10:00:00', 1),
(756, 14, '2025-11-20', '11:00:00', 1),
(757, 15, '2025-11-17', '08:00:00', 1),
(758, 15, '2025-11-17', '08:30:00', 1),
(759, 15, '2025-11-17', '09:00:00', 1),
(760, 15, '2025-11-17', '09:30:00', 1),
(761, 15, '2025-11-17', '10:00:00', 1),
(762, 15, '2025-11-17', '10:30:00', 1),
(763, 15, '2025-11-17', '11:00:00', 1),
(764, 15, '2025-11-17', '11:30:00', 1),
(765, 15, '2025-11-18', '08:00:00', 1),
(766, 15, '2025-11-18', '08:30:00', 1),
(767, 15, '2025-11-18', '09:00:00', 1),
(768, 15, '2025-11-18', '09:30:00', 1),
(769, 15, '2025-11-18', '10:00:00', 1),
(770, 15, '2025-11-18', '10:30:00', 1),
(771, 15, '2025-11-18', '11:00:00', 1),
(772, 15, '2025-11-18', '11:30:00', 1),
(773, 15, '2025-11-19', '14:00:00', 1),
(774, 15, '2025-11-19', '14:30:00', 0),
(775, 15, '2025-11-19', '15:00:00', 1),
(776, 15, '2025-11-19', '15:30:00', 1),
(777, 15, '2025-11-20', '08:00:00', 1),
(778, 15, '2025-11-20', '09:00:00', 1),
(779, 15, '2025-11-20', '10:00:00', 1),
(780, 15, '2025-11-20', '11:00:00', 1),
(781, 16, '2025-11-24', '08:00:00', 1),
(782, 16, '2025-11-24', '08:30:00', 1),
(783, 16, '2025-11-24', '09:00:00', 1),
(784, 16, '2025-11-24', '09:30:00', 1),
(785, 16, '2025-11-24', '10:00:00', 1),
(786, 16, '2025-11-24', '10:30:00', 1),
(787, 16, '2025-11-24', '11:00:00', 1),
(788, 16, '2025-11-24', '11:30:00', 1),
(789, 16, '2025-11-24', '14:00:00', 1),
(790, 16, '2025-11-24', '14:30:00', 1),
(791, 16, '2025-11-24', '15:00:00', 1),
(792, 16, '2025-11-24', '15:30:00', 1),
(793, 16, '2025-11-25', '08:00:00', 1),
(794, 16, '2025-11-25', '08:30:00', 0),
(795, 16, '2025-11-25', '09:00:00', 1),
(796, 16, '2025-11-25', '09:30:00', 1),
(797, 16, '2025-11-25', '10:00:00', 1),
(798, 16, '2025-11-25', '10:30:00', 1),
(799, 16, '2025-11-25', '11:00:00', 1),
(800, 16, '2025-11-25', '11:30:00', 1),
(801, 16, '2025-11-26', '14:00:00', 1),
(802, 16, '2025-11-26', '14:30:00', 1),
(803, 16, '2025-11-26', '15:00:00', 1),
(804, 16, '2025-11-26', '15:30:00', 1),
(805, 16, '2025-11-27', '08:00:00', 1),
(806, 16, '2025-11-27', '09:00:00', 1),
(807, 16, '2025-11-27', '10:00:00', 1),
(808, 16, '2025-11-27', '11:00:00', 1),
(809, 17, '2025-11-24', '08:00:00', 1),
(810, 17, '2025-11-24', '08:30:00', 1),
(811, 17, '2025-11-24', '09:00:00', 1),
(812, 17, '2025-11-24', '09:30:00', 1),
(813, 17, '2025-11-24', '10:00:00', 1),
(814, 17, '2025-11-24', '10:30:00', 1),
(815, 17, '2025-11-24', '11:00:00', 1),
(816, 17, '2025-11-24', '11:30:00', 1),
(817, 17, '2025-11-25', '08:00:00', 1),
(818, 17, '2025-11-25', '08:30:00', 1),
(819, 17, '2025-11-25', '09:00:00', 1),
(820, 17, '2025-11-25', '09:30:00', 1),
(821, 17, '2025-11-25', '10:00:00', 1),
(822, 17, '2025-11-25', '10:30:00', 1),
(823, 17, '2025-11-25', '11:00:00', 1),
(824, 17, '2025-11-25', '11:30:00', 1),
(825, 17, '2025-11-26', '14:00:00', 1),
(826, 17, '2025-11-26', '14:30:00', 1),
(827, 17, '2025-11-26', '15:00:00', 1),
(828, 17, '2025-11-26', '15:30:00', 1),
(829, 17, '2025-11-27', '08:00:00', 1),
(830, 17, '2025-11-27', '09:00:00', 1),
(831, 17, '2025-11-27', '10:00:00', 1),
(832, 17, '2025-11-27', '11:00:00', 1),
(833, 18, '2025-11-24', '08:00:00', 1),
(834, 18, '2025-11-24', '08:30:00', 1),
(835, 18, '2025-11-24', '09:00:00', 1),
(836, 18, '2025-11-24', '09:30:00', 1),
(837, 18, '2025-11-24', '10:00:00', 1),
(838, 18, '2025-11-24', '10:30:00', 1),
(839, 18, '2025-11-24', '11:00:00', 1),
(840, 18, '2025-11-24', '11:30:00', 1),
(841, 18, '2025-11-25', '14:00:00', 1),
(842, 18, '2025-11-25', '14:30:00', 1),
(843, 18, '2025-11-25', '15:00:00', 1),
(844, 18, '2025-11-25', '15:30:00', 1),
(845, 18, '2025-11-26', '08:00:00', 1),
(846, 18, '2025-11-26', '08:30:00', 1),
(847, 18, '2025-11-26', '09:00:00', 1),
(848, 18, '2025-11-26', '09:30:00', 1),
(849, 18, '2025-11-26', '10:00:00', 1),
(850, 18, '2025-11-26', '10:30:00', 1),
(851, 18, '2025-11-26', '11:00:00', 1),
(852, 18, '2025-11-26', '11:30:00', 1),
(853, 18, '2025-11-27', '08:00:00', 1),
(854, 18, '2025-11-27', '09:00:00', 1),
(855, 18, '2025-11-27', '10:00:00', 1),
(856, 18, '2025-11-27', '11:00:00', 1),
(857, 19, '2025-11-24', '08:00:00', 1),
(858, 19, '2025-11-24', '08:30:00', 1),
(859, 19, '2025-11-24', '09:00:00', 0),
(860, 19, '2025-11-24', '09:30:00', 1),
(861, 19, '2025-11-24', '10:00:00', 1),
(862, 19, '2025-11-24', '10:30:00', 1),
(863, 19, '2025-11-24', '11:00:00', 1),
(864, 19, '2025-11-24', '11:30:00', 1),
(865, 19, '2025-11-25', '08:00:00', 1),
(866, 19, '2025-11-25', '08:30:00', 1),
(867, 19, '2025-11-25', '09:00:00', 1),
(868, 19, '2025-11-25', '09:30:00', 1),
(869, 19, '2025-11-25', '10:00:00', 1),
(870, 19, '2025-11-25', '10:30:00', 1),
(871, 19, '2025-11-25', '11:00:00', 1),
(872, 19, '2025-11-25', '11:30:00', 1),
(873, 19, '2025-11-26', '14:00:00', 1),
(874, 19, '2025-11-26', '14:30:00', 1),
(875, 19, '2025-11-26', '15:00:00', 1),
(876, 19, '2025-11-26', '15:30:00', 1),
(877, 19, '2025-11-27', '08:00:00', 1),
(878, 19, '2025-11-27', '09:00:00', 1),
(879, 19, '2025-11-27', '10:00:00', 1),
(880, 19, '2025-11-27', '11:00:00', 1),
(881, 20, '2025-11-24', '08:00:00', 1),
(882, 20, '2025-11-24', '08:30:00', 1),
(883, 20, '2025-11-24', '09:00:00', 1),
(884, 20, '2025-11-24', '09:30:00', 1),
(885, 20, '2025-11-24', '10:00:00', 1),
(886, 20, '2025-11-24', '10:30:00', 1),
(887, 20, '2025-11-24', '11:00:00', 1),
(888, 20, '2025-11-24', '11:30:00', 1),
(889, 20, '2025-11-25', '08:00:00', 1),
(890, 20, '2025-11-25', '08:30:00', 1),
(891, 20, '2025-11-25', '09:00:00', 1),
(892, 20, '2025-11-25', '09:30:00', 1),
(893, 20, '2025-11-25', '10:00:00', 1),
(894, 20, '2025-11-25', '10:30:00', 1),
(895, 20, '2025-11-25', '11:00:00', 1),
(896, 20, '2025-11-25', '11:30:00', 1),
(897, 20, '2025-11-26', '14:00:00', 1),
(898, 20, '2025-11-26', '14:30:00', 1),
(899, 20, '2025-11-26', '15:00:00', 1),
(900, 20, '2025-11-26', '15:30:00', 1),
(901, 20, '2025-11-27', '08:00:00', 1),
(902, 20, '2025-11-27', '09:00:00', 1),
(903, 20, '2025-11-27', '10:00:00', 1),
(904, 20, '2025-11-27', '11:00:00', 1),
(905, 21, '2025-11-03', '08:00:00', 1),
(906, 21, '2025-11-03', '08:30:00', 0),
(907, 21, '2025-11-03', '09:00:00', 1),
(908, 21, '2025-11-03', '09:30:00', 1),
(909, 21, '2025-11-03', '10:00:00', 1),
(910, 21, '2025-11-03', '10:30:00', 1),
(911, 21, '2025-11-03', '11:00:00', 1),
(912, 21, '2025-11-03', '11:30:00', 1),
(913, 21, '2025-11-03', '14:00:00', 1),
(914, 21, '2025-11-03', '14:30:00', 1),
(915, 21, '2025-11-03', '15:00:00', 1),
(916, 21, '2025-11-03', '15:30:00', 1),
(917, 21, '2025-11-10', '08:00:00', 1),
(918, 21, '2025-11-10', '08:30:00', 1),
(919, 21, '2025-11-10', '09:00:00', 1),
(920, 21, '2025-11-10', '09:30:00', 1),
(921, 21, '2025-11-10', '10:00:00', 1),
(922, 21, '2025-11-10', '10:30:00', 1),
(923, 21, '2025-11-10', '11:00:00', 1),
(924, 21, '2025-11-10', '11:30:00', 0),
(925, 21, '2025-11-17', '08:00:00', 1),
(926, 21, '2025-11-17', '08:30:00', 1),
(927, 21, '2025-11-17', '09:00:00', 1),
(928, 21, '2025-11-17', '09:30:00', 1),
(929, 21, '2025-11-17', '10:00:00', 1),
(930, 21, '2025-11-17', '10:30:00', 1),
(931, 21, '2025-11-17', '11:00:00', 1),
(932, 21, '2025-11-17', '11:30:00', 1),
(933, 21, '2025-11-24', '08:00:00', 1),
(934, 21, '2025-11-24', '08:30:00', 1),
(935, 21, '2025-11-24', '09:00:00', 1),
(936, 21, '2025-11-24', '09:30:00', 1),
(937, 21, '2025-11-24', '10:00:00', 1),
(938, 21, '2025-11-24', '10:30:00', 1),
(939, 21, '2025-11-24', '11:00:00', 1),
(940, 21, '2025-11-24', '11:30:00', 1),
(941, 22, '2025-11-04', '08:00:00', 1),
(942, 22, '2025-11-04', '08:30:00', 1),
(943, 22, '2025-11-04', '09:00:00', 1),
(944, 22, '2025-11-04', '09:30:00', 1),
(945, 22, '2025-11-04', '10:00:00', 1),
(946, 22, '2025-11-04', '10:30:00', 1),
(947, 22, '2025-11-04', '11:00:00', 1),
(948, 22, '2025-11-04', '11:30:00', 1),
(949, 22, '2025-11-04', '14:00:00', 1),
(950, 22, '2025-11-04', '14:30:00', 1),
(951, 22, '2025-11-04', '15:00:00', 1),
(952, 22, '2025-11-04', '15:30:00', 1),
(953, 22, '2025-11-11', '08:00:00', 1),
(954, 22, '2025-11-11', '08:30:00', 1),
(955, 22, '2025-11-11', '09:00:00', 1),
(956, 22, '2025-11-11', '09:30:00', 1),
(957, 22, '2025-11-11', '10:00:00', 1),
(958, 22, '2025-11-11', '10:30:00', 1),
(959, 22, '2025-11-11', '11:00:00', 1),
(960, 22, '2025-11-11', '11:30:00', 1),
(961, 22, '2025-11-18', '08:00:00', 1),
(962, 22, '2025-11-18', '08:30:00', 1),
(963, 22, '2025-11-18', '09:00:00', 1),
(964, 22, '2025-11-18', '09:30:00', 1),
(965, 22, '2025-11-18', '10:00:00', 1),
(966, 22, '2025-11-18', '10:30:00', 1),
(967, 22, '2025-11-18', '11:00:00', 1),
(968, 22, '2025-11-18', '11:30:00', 1),
(969, 22, '2025-11-25', '08:00:00', 1),
(970, 22, '2025-11-25', '08:30:00', 1),
(971, 22, '2025-11-25', '09:00:00', 1),
(972, 22, '2025-11-25', '09:30:00', 1),
(973, 22, '2025-11-25', '10:00:00', 1),
(974, 22, '2025-11-25', '10:30:00', 1),
(975, 22, '2025-11-25', '11:00:00', 1),
(976, 22, '2025-11-25', '11:30:00', 1),
(977, 23, '2025-11-05', '08:00:00', 1),
(978, 23, '2025-11-05', '08:30:00', 1),
(979, 23, '2025-11-05', '09:00:00', 1),
(980, 23, '2025-11-05', '09:30:00', 1),
(981, 23, '2025-11-05', '10:00:00', 1),
(982, 23, '2025-11-05', '10:30:00', 1),
(983, 23, '2025-11-05', '11:00:00', 1),
(984, 23, '2025-11-05', '11:30:00', 1),
(985, 23, '2025-11-05', '14:00:00', 1),
(986, 23, '2025-11-05', '14:30:00', 1),
(987, 23, '2025-11-05', '15:00:00', 1),
(988, 23, '2025-11-05', '15:30:00', 1),
(989, 23, '2025-11-12', '08:00:00', 0),
(990, 23, '2025-11-12', '08:30:00', 1),
(991, 23, '2025-11-12', '09:00:00', 1),
(992, 23, '2025-11-12', '09:30:00', 1),
(993, 23, '2025-11-12', '10:00:00', 1),
(994, 23, '2025-11-12', '10:30:00', 1),
(995, 23, '2025-11-12', '11:00:00', 1),
(996, 23, '2025-11-12', '11:30:00', 1),
(997, 23, '2025-11-19', '08:00:00', 1),
(998, 23, '2025-11-19', '08:30:00', 1),
(999, 23, '2025-11-19', '09:00:00', 1),
(1000, 23, '2025-11-19', '09:30:00', 1),
(1001, 23, '2025-11-19', '10:00:00', 1),
(1002, 23, '2025-11-19', '10:30:00', 1),
(1003, 23, '2025-11-19', '11:00:00', 1),
(1004, 23, '2025-11-19', '11:30:00', 1),
(1005, 23, '2025-11-26', '08:00:00', 1),
(1006, 23, '2025-11-26', '08:30:00', 1),
(1007, 23, '2025-11-26', '09:00:00', 1),
(1008, 23, '2025-11-26', '09:30:00', 1),
(1009, 23, '2025-11-26', '10:00:00', 1),
(1010, 23, '2025-11-26', '10:30:00', 1),
(1011, 23, '2025-11-26', '11:00:00', 1),
(1012, 23, '2025-11-26', '11:30:00', 1),
(1013, 24, '2025-11-06', '08:00:00', 1),
(1014, 24, '2025-11-06', '08:30:00', 1),
(1015, 24, '2025-11-06', '09:00:00', 1),
(1016, 24, '2025-11-06', '09:30:00', 1),
(1017, 24, '2025-11-06', '10:00:00', 1),
(1018, 24, '2025-11-06', '10:30:00', 1),
(1019, 24, '2025-11-06', '11:00:00', 1),
(1020, 24, '2025-11-06', '11:30:00', 1),
(1021, 24, '2025-11-06', '14:00:00', 1),
(1022, 24, '2025-11-06', '14:30:00', 1),
(1023, 24, '2025-11-06', '15:00:00', 1),
(1024, 24, '2025-11-06', '15:30:00', 1),
(1025, 24, '2025-11-13', '08:00:00', 1),
(1026, 24, '2025-11-13', '08:30:00', 1),
(1027, 24, '2025-11-13', '09:00:00', 1),
(1028, 24, '2025-11-13', '09:30:00', 1),
(1029, 24, '2025-11-13', '10:00:00', 1),
(1030, 24, '2025-11-13', '10:30:00', 1),
(1031, 24, '2025-11-13', '11:00:00', 1),
(1032, 24, '2025-11-13', '11:30:00', 1),
(1033, 24, '2025-11-20', '08:00:00', 1),
(1034, 24, '2025-11-20', '08:30:00', 1),
(1035, 24, '2025-11-20', '09:00:00', 1),
(1036, 24, '2025-11-20', '09:30:00', 1),
(1037, 24, '2025-11-20', '10:00:00', 1),
(1038, 24, '2025-11-20', '10:30:00', 1),
(1039, 24, '2025-11-20', '11:00:00', 1),
(1040, 24, '2025-11-20', '11:30:00', 1),
(1041, 24, '2025-11-27', '08:00:00', 1),
(1042, 24, '2025-11-27', '08:30:00', 1),
(1043, 24, '2025-11-27', '09:00:00', 1),
(1044, 24, '2025-11-27', '09:30:00', 1),
(1045, 24, '2025-11-27', '10:00:00', 1),
(1046, 24, '2025-11-27', '10:30:00', 1),
(1047, 24, '2025-11-27', '11:00:00', 1),
(1048, 24, '2025-11-27', '11:30:00', 1),
(1049, 25, '2025-11-07', '08:00:00', 1),
(1050, 25, '2025-11-07', '08:30:00', 1),
(1051, 25, '2025-11-07', '09:00:00', 1),
(1052, 25, '2025-11-07', '09:30:00', 1),
(1053, 25, '2025-11-07', '10:00:00', 1),
(1054, 25, '2025-11-07', '10:30:00', 1),
(1055, 25, '2025-11-07', '11:00:00', 1),
(1056, 25, '2025-11-07', '11:30:00', 1),
(1057, 25, '2025-11-07', '14:00:00', 1),
(1058, 25, '2025-11-07', '14:30:00', 1),
(1059, 25, '2025-11-07', '15:00:00', 1),
(1060, 25, '2025-11-07', '15:30:00', 1),
(1061, 25, '2025-11-14', '08:00:00', 1),
(1062, 25, '2025-11-14', '08:30:00', 1),
(1063, 25, '2025-11-14', '09:00:00', 1),
(1064, 25, '2025-11-14', '09:30:00', 1),
(1065, 25, '2025-11-14', '10:00:00', 1),
(1066, 25, '2025-11-14', '10:30:00', 1),
(1067, 25, '2025-11-14', '11:00:00', 1),
(1068, 25, '2025-11-14', '11:30:00', 1),
(1069, 25, '2025-11-21', '08:00:00', 1),
(1070, 25, '2025-11-21', '08:30:00', 1),
(1071, 25, '2025-11-21', '09:00:00', 1),
(1072, 25, '2025-11-21', '09:30:00', 1),
(1073, 25, '2025-11-21', '10:00:00', 1),
(1074, 25, '2025-11-21', '10:30:00', 1),
(1075, 25, '2025-11-21', '11:00:00', 1),
(1076, 25, '2025-11-21', '11:30:00', 1),
(1077, 25, '2025-11-28', '08:00:00', 1),
(1078, 25, '2025-11-28', '08:30:00', 1),
(1079, 25, '2025-11-28', '09:00:00', 1),
(1080, 25, '2025-11-28', '09:30:00', 1),
(1081, 25, '2025-11-28', '10:00:00', 1),
(1082, 25, '2025-11-28', '10:30:00', 1),
(1083, 25, '2025-11-28', '11:00:00', 1),
(1084, 25, '2025-11-28', '11:30:00', 1),
(1085, 2, '2025-11-02', '13:00:00', 0),
(1086, 2, '2025-11-03', '13:15:00', 0),
(1087, 2, '2025-11-04', '04:30:00', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `motivos_cancelacion`
--

CREATE TABLE `motivos_cancelacion` (
  `id_motivo` int(11) NOT NULL,
  `nombre_motivo` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `motivos_cancelacion`
--

INSERT INTO `motivos_cancelacion` (`id_motivo`, `nombre_motivo`) VALUES
(1, 'Calamidad doméstica'),
(2, 'Cambio de horario laboral'),
(3, 'Cita previa en otra institución'),
(4, 'Compromiso laboral obligatorio'),
(5, 'Dificultades económicas'),
(6, 'Mejoría del estado de salud'),
(7, 'Mudanza a otra ciudad'),
(8, 'Problemas de transporte');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificaciones`
--

CREATE TABLE `notificaciones` (
  `id_notificacion` int(11) NOT NULL,
  `id_cita` int(11) DEFAULT NULL,
  `tipo_notificacion` varchar(50) NOT NULL,
  `destinatario` varchar(200) NOT NULL,
  `asunto` varchar(200) DEFAULT NULL,
  `mensaje` text NOT NULL,
  `enviado` tinyint(1) DEFAULT 0,
  `fecha_programada` timestamp NULL DEFAULT NULL,
  `fecha_enviado` timestamp NULL DEFAULT NULL,
  `intentos_envio` int(11) DEFAULT 0,
  `error_envio` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pacientes`
--

CREATE TABLE `pacientes` (
  `id_paciente` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_tipo_doc` int(11) NOT NULL,
  `numero_documento` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `correo` varchar(150) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pacientes`
--

INSERT INTO `pacientes` (`id_paciente`, `id_usuario`, `id_tipo_doc`, `numero_documento`, `nombre`, `apellido`, `correo`, `telefono`) VALUES
(1, 26, 1, '1001001001', 'Juan', 'Pérez', 'paciente1@eps.co', '3001112233'),
(2, 27, 2, '1002002002', 'Ana', 'Gómez', 'paciente2@eps.co', '3004445566'),
(3, 28, 1, '1003003003', 'Carlos', 'Rodríguez', 'paciente3@eps.co', '3007778899'),
(4, 29, 3, '1004004004', 'María', 'López', 'paciente4@eps.co', '3009990011'),
(5, 30, 1, '1005005005', 'Pedro', 'Sánchez', 'paciente5@eps.co', '3002223344'),
(6, 31, 2, '1006006006', 'Laura', 'Díaz', 'paciente6@eps.co', '3005556677'),
(7, 32, 4, '1007007007', 'Felipe', 'Muñoz', 'cgomez.osorno@udea.edu.co', '3008889900'),
(8, 33, 1, '1008008008', 'Sofía', 'Castro', 'carolinagomez1232006@gmail.com', '3001110022'),
(9, 34, 1, '1009009009', 'Diego', 'Vargas', 'paciente9@eps.co', '3003334455'),
(10, 35, 5, '1010101010', 'Valeria', 'Ruiz', 'paciente10@eps.co', '3006667788');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `profesionales`
--

CREATE TABLE `profesionales` (
  `id_profesional` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_tipo_doc` int(11) NOT NULL,
  `numero_documento` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `titulo_profesional` varchar(100) NOT NULL,
  `anos_experiencia` int(11) DEFAULT NULL,
  `id_estado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `profesionales`
--

INSERT INTO `profesionales` (`id_profesional`, `id_usuario`, `id_tipo_doc`, `numero_documento`, `nombre`, `apellido`, `titulo_profesional`, `anos_experiencia`, `id_estado`) VALUES
(1, 1, 1, '1234567890', 'Sara', 'Martínez', 'Médica Pediatra', 10, 1),
(2, 2, 1, '1234567891', 'Andrés', 'Gómez', 'Médico Cardiólogo', 15, 1),
(3, 3, 1, '1234567892', 'Laura', 'Pérez', 'Médica Dermatóloga', 8, 1),
(4, 4, 1, '1234567893', 'Carlos', 'Rojas', 'Médico Ginecólogo', 18, 1),
(5, 5, 1, '1234567894', 'Mario', 'Sánchez', 'Médico Neurólogo', 12, 1),
(6, 6, 1, '1234567895', 'Ana', 'López', 'Odontóloga', 9, 1),
(7, 7, 1, '1234567896', 'Juan', 'Ramírez', 'Ortopedista', 22, 1),
(8, 8, 1, '1234567897', 'Paula', 'Castro', 'Médica Oftalmóloga', 14, 1),
(9, 9, 1, '1234567898', 'Daniel', 'Jiménez', 'Médico Urólogo', 11, 1),
(10, 10, 1, '1234567899', 'Sofía', 'Ruiz', 'Psicóloga', 7, 1),
(11, 11, 1, '1234567900', 'Luis', 'Fernández', 'Médico Internista', 19, 1),
(12, 12, 1, '1234567901', 'Camila', 'Guzmán', 'Nutricionista', 6, 1),
(13, 13, 1, '1234567902', 'David', 'Mora', 'Fisioterapeuta', 13, 1),
(14, 14, 1, '1234567903', 'Valentina', 'Vargas', 'Médica Oncólogo', 17, 1),
(15, 15, 1, '1234567904', 'Felipe', 'Herrera', 'Médico Radiólogo', 20, 1),
(16, 16, 1, '1234567905', 'Isabella', 'Muñoz', 'Anestesióloga', 16, 1),
(17, 17, 1, '1234567906', 'Jorge', 'Ortiz', 'Cirujano General', 25, 1),
(18, 18, 1, '1234567907', 'Claudia', 'García', 'Endocrinóloga', 10, 1),
(19, 19, 1, '1234567908', 'Hugo', 'Díaz', 'Gastroenterólogo', 14, 1),
(20, 20, 1, '1234567909', 'Patricia', 'Silva', 'Médica Familiar', 9, 1),
(21, 21, 1, '1234567910', 'Esteban', 'Castañeda', 'Alergólogo', 11, 1),
(22, 22, 1, '1234567911', 'Elena', 'Pardo', 'Otorrinolaringóloga', 15, 1),
(23, 23, 1, '1234567912', 'Ricardo', 'Pineda', 'Médico Neurólogo', 13, 1),
(24, 24, 1, '1234567913', 'Liliana', 'Cortés', 'Cardióloga', 18, 1),
(25, 25, 1, '1234567914', 'Gustavo', 'Quiroga', 'Cirujano Plástico', 21, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `profesionales_especialidades`
--

CREATE TABLE `profesionales_especialidades` (
  `id_profesional` int(11) NOT NULL,
  `id_especialidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `profesionales_especialidades`
--

INSERT INTO `profesionales_especialidades` (`id_profesional`, `id_especialidad`) VALUES
(1, 2),
(1, 28),
(2, 1),
(2, 11),
(3, 3),
(4, 4),
(5, 5),
(5, 10),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(11, 19),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(17, 51),
(18, 18),
(19, 19),
(20, 28),
(21, 30),
(22, 31),
(23, 5),
(24, 1),
(24, 36),
(25, 37);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `profesionales_sedes`
--

CREATE TABLE `profesionales_sedes` (
  `id_profesional` int(11) NOT NULL,
  `id_sede` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `profesionales_sedes`
--

INSERT INTO `profesionales_sedes` (`id_profesional`, `id_sede`) VALUES
(1, 2),
(2, 1),
(3, 3),
(4, 4),
(5, 2),
(6, 7),
(7, 8),
(8, 9),
(9, 10),
(10, 11),
(11, 12),
(12, 13),
(13, 14),
(14, 15),
(15, 16),
(16, 17),
(17, 18),
(18, 19),
(19, 20),
(20, 21),
(21, 22),
(22, 23),
(23, 24),
(24, 25),
(25, 26);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id_rol` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id_rol`, `nombre`) VALUES
(2, 'Paciente'),
(1, 'Profesional');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sedes`
--

CREATE TABLE `sedes` (
  `id_sede` int(11) NOT NULL,
  `nombre_sede` varchar(100) NOT NULL,
  `direccion` varchar(150) NOT NULL,
  `id_ciudad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sedes`
--

INSERT INTO `sedes` (`id_sede`, `nombre_sede`, `direccion`, `id_ciudad`) VALUES
(1, 'Clínica de la 80', 'Calle 80 # 35-12', 2),
(2, 'Centro Médico Galerías', 'Avenida Caracas # 53-90', 1),
(3, 'IPS de la Loma', 'Carrera 56 # 15-30', 3),
(4, 'Hospital del Norte', 'Calle 50 # 8C-22', 4),
(5, 'Unidad de Urgencias', 'Carrera 5 # 71-45', 5),
(6, 'Clínica de Especialidades', 'Avenida Quebrada Seca # 30-10', 6),
(7, 'Sede Médica de la 20', 'Calle 20 # 25-15', 8),
(8, 'Hospital de la Pradera', 'Carrera 7 # 28-56', 7),
(9, 'IPS Cúcuta Centro', 'Avenida 0 # 13-05', 9),
(10, 'Centro de Salud Bello', 'Carrera 50 # 45-67', 10),
(11, 'Sede Itagüí', 'Calle 70 # 50-89', 11),
(12, 'Clínica Envigado', 'Carrera 43A # 36 Sur-12', 12),
(13, 'IPS Floridablanca', 'Calle 20 # 22-34', 13),
(14, 'Hospital Girón', 'Carrera 28 # 31-50', 14),
(15, 'Clínica Soledad', 'Avenida Murillo # 15-40', 15),
(16, 'Centro Médico Malambo', 'Calle 10 # 5-10', 16),
(17, 'Sede Soacha', 'Calle 22 # 11-20', 17),
(18, 'IPS Madrid', 'Carrera 3 # 4-50', 18),
(19, 'Clínica Zipaquirá', 'Calle 8 # 9-10', 19),
(20, 'Hospital Palmira', 'Carrera 28 # 42-12', 20),
(21, 'Centro de Salud Tuluá', 'Calle 25 # 25-50', 21),
(22, 'IPS Dosquebradas', 'Avenida Simones # 4-30', 22),
(23, 'Clínica Santa Rosa', 'Carrera 14 # 19-25', 23),
(24, 'Hospital Villavicencio', 'Calle 40 # 25-15', 24),
(25, 'Sede Ibagué', 'Carrera 5 # 32-05', 25),
(26, 'IPS Popayán', 'Calle 5 # 10-20', 26),
(27, 'Clínica Tunja', 'Avenida Norte # 20-30', 27),
(28, 'Hospital Pasto', 'Carrera 27 # 16-55', 28),
(29, 'Centro Médico Montería', 'Calle 29 # 10-15', 29);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_ausencia`
--

CREATE TABLE `tipos_ausencia` (
  `id_tipo` int(11) NOT NULL,
  `nombre_tipo` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipos_ausencia`
--

INSERT INTO `tipos_ausencia` (`id_tipo`, `nombre_tipo`) VALUES
(3, 'Capacitación'),
(6, 'Comisión de Servicios'),
(4, 'Licencia de Maternidad'),
(5, 'Licencia de Paternidad'),
(2, 'Licencia Médica'),
(7, 'Permiso Personal'),
(1, 'Vacaciones');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_documento`
--

CREATE TABLE `tipos_documento` (
  `id_tipo` int(11) NOT NULL,
  `nombre_tipo` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipos_documento`
--

INSERT INTO `tipos_documento` (`id_tipo`, `nombre_tipo`) VALUES
(1, 'Cédula de Ciudadanía'),
(3, 'Cédula de Extranjería'),
(4, 'Pasaporte'),
(5, 'Registro Civil'),
(2, 'Tarjeta de Identidad');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `correo` varchar(150) NOT NULL,
  `contrasena` varchar(200) NOT NULL COMMENT 'encriptada',
  `id_rol` int(11) NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `intentos_fallidos` tinyint(4) NOT NULL DEFAULT 0,
  `bloqueo_hasta` datetime DEFAULT NULL,
  `reset_token` varchar(64) DEFAULT NULL,
  `token_expira` datetime DEFAULT NULL,
  `session_id_activa` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `correo`, `contrasena`, `id_rol`, `activo`, `intentos_fallidos`, `bloqueo_hasta`, `reset_token`, `token_expira`, `session_id_activa`) VALUES
(1, 'carolinagomez1232006@gmail.com', '243c7e2464cdf709c78a9cc76c588e7544e083c3d167a6f5f379b74b2ea77fb7', 1, 1, 0, NULL, '049778ef083c054469fce489284bf3f3e19d71ab3f348584f346e8e0a49f9331', '2025-11-21 17:26:33', NULL),
(2, 'dr.andres.gomez@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(3, 'dra.laura.perez@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(4, 'dr.carlos.rojas@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(5, 'dr.mario.sanchez@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(6, 'dra.ana.lopez@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(7, 'dr.juan.ramirez@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(8, 'dra.paula.castro@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(9, 'dr.daniel.jimenez@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(10, 'dra.sofia.ruiz@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(11, 'dr.luis.fernandez@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(12, 'dra.camila.guzman@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(13, 'dr.david.mora@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(14, 'dra.valentina.vargas@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(15, 'dr.felipe.herrera@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(16, 'dra.isabella.munoz@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(17, 'dr.jorge.ortiz@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(18, 'dra.claudia.garcia@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(19, 'dr.hugo.diaz@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(20, 'dra.patricia.silva@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(21, 'dr.esteban.castaneda@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(22, 'dra.elena.pardo@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(23, 'dr.ricardo.pineda@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(24, 'dra.liliana.cortes@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(25, 'dr.gustavo.quiroga@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 1, 1, 0, NULL, NULL, NULL, NULL),
(26, 'paciente1@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 2, 1, 0, NULL, NULL, NULL, NULL),
(27, 'paciente2@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 2, 1, 0, NULL, NULL, NULL, NULL),
(28, 'paciente3@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 2, 1, 1, NULL, NULL, NULL, NULL),
(29, 'paciente4@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 2, 1, 0, NULL, NULL, NULL, NULL),
(30, 'paciente5@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 2, 1, 0, NULL, NULL, NULL, NULL),
(31, 'paciente6@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 2, 1, 0, NULL, NULL, NULL, NULL),
(32, 'cgomez.osorno@udea.edu.co', 'a01a7d6676e366b3319bc25d3f5744ed72decfaa51154eaba8711933e2a2a969', 2, 1, 0, NULL, NULL, NULL, NULL),
(33, 'carolinagomez1232006@gmail.com', '243c7e2464cdf709c78a9cc76c588e7544e083c3d167a6f5f379b74b2ea77fb7', 2, 1, 0, NULL, 'c60f38967ba9f19a7f1b9d721cd2c36929facdb2fccd59f9039c609908420285', '2025-11-21 17:01:30', NULL),
(34, 'paciente9@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 2, 1, 0, NULL, NULL, NULL, NULL),
(35, 'paciente10@eps.co', '9b8769a4a742959a2d0298c36fb70623f2dfacda8436237df08d8dfd5b37374c', 2, 1, 0, NULL, NULL, NULL, NULL);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `ausencias_profesionales`
--
ALTER TABLE `ausencias_profesionales`
  ADD PRIMARY KEY (`id_ausencia`),
  ADD KEY `fk_ausencias_profesional` (`id_profesional`),
  ADD KEY `fk_ausencias_tipo` (`id_tipo`);

--
-- Indices de la tabla `citas`
--
ALTER TABLE `citas`
  ADD PRIMARY KEY (`id_cita`),
  ADD KEY `fk_citas_paciente` (`id_paciente`),
  ADD KEY `fk_citas_profesional` (`id_profesional`),
  ADD KEY `fk_citas_sede` (`id_sede`),
  ADD KEY `fk_citas_especialidad` (`id_especialidad`),
  ADD KEY `fk_citas_horario` (`id_horario`),
  ADD KEY `fk_citas_estado` (`id_estado`);

--
-- Indices de la tabla `ciudades`
--
ALTER TABLE `ciudades`
  ADD PRIMARY KEY (`id_ciudad`),
  ADD UNIQUE KEY `nombre_ciudad` (`nombre_ciudad`);

--
-- Indices de la tabla `especialidades`
--
ALTER TABLE `especialidades`
  ADD PRIMARY KEY (`id_especialidad`),
  ADD UNIQUE KEY `nombre_especialidad` (`nombre_especialidad`);

--
-- Indices de la tabla `estados_cita`
--
ALTER TABLE `estados_cita`
  ADD PRIMARY KEY (`id_estado`),
  ADD UNIQUE KEY `nombre_estado` (`nombre_estado`);

--
-- Indices de la tabla `estados_profesional`
--
ALTER TABLE `estados_profesional`
  ADD PRIMARY KEY (`id_estado`),
  ADD UNIQUE KEY `nombre_estado` (`nombre_estado`);

--
-- Indices de la tabla `historiales_cita`
--
ALTER TABLE `historiales_cita`
  ADD PRIMARY KEY (`id_historial`),
  ADD KEY `fk_historial_cita` (`id_cita`),
  ADD KEY `fk_historial_estado` (`id_estado`);

--
-- Indices de la tabla `historial_cancelaciones`
--
ALTER TABLE `historial_cancelaciones`
  ADD PRIMARY KEY (`id_cancelacion`),
  ADD UNIQUE KEY `id_cita` (`id_cita`),
  ADD KEY `id_paciente` (`id_paciente`),
  ADD KEY `id_motivo` (`id_motivo`);

--
-- Indices de la tabla `historial_modificaciones`
--
ALTER TABLE `historial_modificaciones`
  ADD PRIMARY KEY (`id_modificacion`),
  ADD UNIQUE KEY `id_cita` (`id_cita`),
  ADD KEY `id_profesional_anterior` (`id_profesional_anterior`),
  ADD KEY `id_sede_anterior` (`id_sede_anterior`),
  ADD KEY `id_profesional_nuevo` (`id_profesional_nuevo`),
  ADD KEY `id_sede_nueva` (`id_sede_nueva`);

--
-- Indices de la tabla `horarios_profesionales`
--
ALTER TABLE `horarios_profesionales`
  ADD PRIMARY KEY (`id_horario`),
  ADD UNIQUE KEY `uk_profesional_fecha_hora` (`id_profesional`,`fecha`,`hora`);

--
-- Indices de la tabla `motivos_cancelacion`
--
ALTER TABLE `motivos_cancelacion`
  ADD PRIMARY KEY (`id_motivo`),
  ADD UNIQUE KEY `nombre_motivo` (`nombre_motivo`);

--
-- Indices de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD PRIMARY KEY (`id_notificacion`),
  ADD KEY `fk_notificaciones_cita` (`id_cita`);

--
-- Indices de la tabla `pacientes`
--
ALTER TABLE `pacientes`
  ADD PRIMARY KEY (`id_paciente`),
  ADD UNIQUE KEY `numero_documento` (`numero_documento`),
  ADD UNIQUE KEY `id_usuario` (`id_usuario`),
  ADD KEY `fk_pacientes_tipo_doc` (`id_tipo_doc`);

--
-- Indices de la tabla `profesionales`
--
ALTER TABLE `profesionales`
  ADD PRIMARY KEY (`id_profesional`),
  ADD UNIQUE KEY `numero_documento` (`numero_documento`),
  ADD UNIQUE KEY `id_usuario` (`id_usuario`),
  ADD KEY `fk_profesionales_tipo_doc` (`id_tipo_doc`),
  ADD KEY `fk_profesionales_estado` (`id_estado`);

--
-- Indices de la tabla `profesionales_especialidades`
--
ALTER TABLE `profesionales_especialidades`
  ADD PRIMARY KEY (`id_profesional`,`id_especialidad`),
  ADD KEY `fk_prof_esp_especialidad` (`id_especialidad`);

--
-- Indices de la tabla `profesionales_sedes`
--
ALTER TABLE `profesionales_sedes`
  ADD PRIMARY KEY (`id_profesional`,`id_sede`),
  ADD KEY `fk_prof_sede_sede` (`id_sede`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id_rol`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `sedes`
--
ALTER TABLE `sedes`
  ADD PRIMARY KEY (`id_sede`),
  ADD KEY `fk_sedes_ciudad` (`id_ciudad`);

--
-- Indices de la tabla `tipos_ausencia`
--
ALTER TABLE `tipos_ausencia`
  ADD PRIMARY KEY (`id_tipo`),
  ADD UNIQUE KEY `nombre_tipo` (`nombre_tipo`);

--
-- Indices de la tabla `tipos_documento`
--
ALTER TABLE `tipos_documento`
  ADD PRIMARY KEY (`id_tipo`),
  ADD UNIQUE KEY `nombre_tipo` (`nombre_tipo`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD KEY `fk_usuarios_rol` (`id_rol`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `ausencias_profesionales`
--
ALTER TABLE `ausencias_profesionales`
  MODIFY `id_ausencia` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `citas`
--
ALTER TABLE `citas`
  MODIFY `id_cita` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT de la tabla `ciudades`
--
ALTER TABLE `ciudades`
  MODIFY `id_ciudad` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `especialidades`
--
ALTER TABLE `especialidades`
  MODIFY `id_especialidad` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=79;

--
-- AUTO_INCREMENT de la tabla `estados_cita`
--
ALTER TABLE `estados_cita`
  MODIFY `id_estado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `estados_profesional`
--
ALTER TABLE `estados_profesional`
  MODIFY `id_estado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `historiales_cita`
--
ALTER TABLE `historiales_cita`
  MODIFY `id_historial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT de la tabla `historial_cancelaciones`
--
ALTER TABLE `historial_cancelaciones`
  MODIFY `id_cancelacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `historial_modificaciones`
--
ALTER TABLE `historial_modificaciones`
  MODIFY `id_modificacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `horarios_profesionales`
--
ALTER TABLE `horarios_profesionales`
  MODIFY `id_horario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1088;

--
-- AUTO_INCREMENT de la tabla `motivos_cancelacion`
--
ALTER TABLE `motivos_cancelacion`
  MODIFY `id_motivo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  MODIFY `id_notificacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `pacientes`
--
ALTER TABLE `pacientes`
  MODIFY `id_paciente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `profesionales`
--
ALTER TABLE `profesionales`
  MODIFY `id_profesional` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `sedes`
--
ALTER TABLE `sedes`
  MODIFY `id_sede` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `tipos_ausencia`
--
ALTER TABLE `tipos_ausencia`
  MODIFY `id_tipo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `tipos_documento`
--
ALTER TABLE `tipos_documento`
  MODIFY `id_tipo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `ausencias_profesionales`
--
ALTER TABLE `ausencias_profesionales`
  ADD CONSTRAINT `fk_ausencias_profesional` FOREIGN KEY (`id_profesional`) REFERENCES `profesionales` (`id_profesional`),
  ADD CONSTRAINT `fk_ausencias_tipo` FOREIGN KEY (`id_tipo`) REFERENCES `tipos_ausencia` (`id_tipo`);

--
-- Filtros para la tabla `citas`
--
ALTER TABLE `citas`
  ADD CONSTRAINT `fk_citas_especialidad` FOREIGN KEY (`id_especialidad`) REFERENCES `especialidades` (`id_especialidad`),
  ADD CONSTRAINT `fk_citas_estado` FOREIGN KEY (`id_estado`) REFERENCES `estados_cita` (`id_estado`),
  ADD CONSTRAINT `fk_citas_horario` FOREIGN KEY (`id_horario`) REFERENCES `horarios_profesionales` (`id_horario`),
  ADD CONSTRAINT `fk_citas_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `pacientes` (`id_paciente`),
  ADD CONSTRAINT `fk_citas_profesional` FOREIGN KEY (`id_profesional`) REFERENCES `profesionales` (`id_profesional`),
  ADD CONSTRAINT `fk_citas_sede` FOREIGN KEY (`id_sede`) REFERENCES `sedes` (`id_sede`);

--
-- Filtros para la tabla `historiales_cita`
--
ALTER TABLE `historiales_cita`
  ADD CONSTRAINT `fk_historial_cita` FOREIGN KEY (`id_cita`) REFERENCES `citas` (`id_cita`),
  ADD CONSTRAINT `fk_historial_estado` FOREIGN KEY (`id_estado`) REFERENCES `estados_cita` (`id_estado`);

--
-- Filtros para la tabla `historial_cancelaciones`
--
ALTER TABLE `historial_cancelaciones`
  ADD CONSTRAINT `historial_cancelaciones_ibfk_1` FOREIGN KEY (`id_cita`) REFERENCES `citas` (`id_cita`),
  ADD CONSTRAINT `historial_cancelaciones_ibfk_2` FOREIGN KEY (`id_paciente`) REFERENCES `pacientes` (`id_paciente`),
  ADD CONSTRAINT `historial_cancelaciones_ibfk_3` FOREIGN KEY (`id_motivo`) REFERENCES `motivos_cancelacion` (`id_motivo`);

--
-- Filtros para la tabla `historial_modificaciones`
--
ALTER TABLE `historial_modificaciones`
  ADD CONSTRAINT `historial_modificaciones_ibfk_1` FOREIGN KEY (`id_cita`) REFERENCES `citas` (`id_cita`),
  ADD CONSTRAINT `historial_modificaciones_ibfk_2` FOREIGN KEY (`id_profesional_anterior`) REFERENCES `profesionales` (`id_profesional`),
  ADD CONSTRAINT `historial_modificaciones_ibfk_3` FOREIGN KEY (`id_sede_anterior`) REFERENCES `sedes` (`id_sede`),
  ADD CONSTRAINT `historial_modificaciones_ibfk_4` FOREIGN KEY (`id_profesional_nuevo`) REFERENCES `profesionales` (`id_profesional`),
  ADD CONSTRAINT `historial_modificaciones_ibfk_5` FOREIGN KEY (`id_sede_nueva`) REFERENCES `sedes` (`id_sede`);

--
-- Filtros para la tabla `horarios_profesionales`
--
ALTER TABLE `horarios_profesionales`
  ADD CONSTRAINT `fk_horarios_profesional` FOREIGN KEY (`id_profesional`) REFERENCES `profesionales` (`id_profesional`);

--
-- Filtros para la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD CONSTRAINT `fk_notificaciones_cita` FOREIGN KEY (`id_cita`) REFERENCES `citas` (`id_cita`);

--
-- Filtros para la tabla `pacientes`
--
ALTER TABLE `pacientes`
  ADD CONSTRAINT `fk_pacientes_tipo_doc` FOREIGN KEY (`id_tipo_doc`) REFERENCES `tipos_documento` (`id_tipo`),
  ADD CONSTRAINT `fk_pacientes_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `profesionales`
--
ALTER TABLE `profesionales`
  ADD CONSTRAINT `fk_profesionales_estado` FOREIGN KEY (`id_estado`) REFERENCES `estados_profesional` (`id_estado`),
  ADD CONSTRAINT `fk_profesionales_tipo_doc` FOREIGN KEY (`id_tipo_doc`) REFERENCES `tipos_documento` (`id_tipo`),
  ADD CONSTRAINT `fk_profesionales_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `profesionales_especialidades`
--
ALTER TABLE `profesionales_especialidades`
  ADD CONSTRAINT `fk_prof_esp_especialidad` FOREIGN KEY (`id_especialidad`) REFERENCES `especialidades` (`id_especialidad`),
  ADD CONSTRAINT `fk_prof_esp_profesional` FOREIGN KEY (`id_profesional`) REFERENCES `profesionales` (`id_profesional`);

--
-- Filtros para la tabla `profesionales_sedes`
--
ALTER TABLE `profesionales_sedes`
  ADD CONSTRAINT `fk_prof_sede_profesional` FOREIGN KEY (`id_profesional`) REFERENCES `profesionales` (`id_profesional`),
  ADD CONSTRAINT `fk_prof_sede_sede` FOREIGN KEY (`id_sede`) REFERENCES `sedes` (`id_sede`);

--
-- Filtros para la tabla `sedes`
--
ALTER TABLE `sedes`
  ADD CONSTRAINT `fk_sedes_ciudad` FOREIGN KEY (`id_ciudad`) REFERENCES `ciudades` (`id_ciudad`);

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `fk_usuarios_rol` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
