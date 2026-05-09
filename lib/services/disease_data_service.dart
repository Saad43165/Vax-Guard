import 'dart:convert';
import 'package:flutter/services.dart';

class Disease {
  final String id;
  final String name;
  final String description;
  final List<String> symptoms;
  final List<String> prevention;
  final List<String> treatment;
  final String severity;
  final String category;

  Disease({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.prevention,
    required this.treatment,
    required this.severity,
    required this.category,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      symptoms: List<String>.from(json['symptoms']),
      prevention: List<String>.from(json['prevention']),
      treatment: List<String>.from(json['treatment']),
      severity: json['severity'],
      category: json['category'],
    );
  }
}

class DiseaseDataService {
  static final DiseaseDataService instance = DiseaseDataService._();
  DiseaseDataService._();

  final List<Disease> _diseases = [
    Disease(
      id: 'ebola',
      name: 'Ebola Virus Disease',
      description: 'Ebola virus disease (EVD), formerly known as Ebola haemorrhagic fever, is a rare but severe, often fatal illness in humans.',
      symptoms: [
        'Fever',
        'Fatigue',
        'Muscle pain',
        'Headache',
        'Sore throat',
        'Vomiting',
        'Diarrhoea',
        'Rash',
        'Symptoms of impaired kidney and liver function',
        'Internal and external bleeding',
      ],
      prevention: [
        'Avoid contact with blood and body fluids',
        'Practice good hygiene',
        'Avoid contact with items that may have come in contact with an infected person\'s blood or body fluids',
        'Avoid funeral or burial rituals that require handling the body of someone who died from Ebola',
        'Avoid contact with bats and nonhuman primates',
      ],
      treatment: [
        'Supportive care-rehydration with oral or intravenous fluids',
        'Treatment of specific symptoms',
        'Monoclonal antibody treatments (Inmazeb and Ebanga)',
      ],
      severity: 'Critical',
      category: 'Viral Hemorrhagic Fever',
    ),
    Disease(
      id: 'rabies',
      name: 'Rabies',
      description: 'Rabies is a vaccine-preventable, zoonotic, viral disease. Once clinical symptoms appear, rabies is virtually 100% fatal.',
      symptoms: [
        'Fever',
        'Headache',
        'Nausea',
        'Vomiting',
        'Agitation',
        'Anxiety',
        'Confusion',
        'Hyperactivity',
        'Difficulty swallowing',
        'Excessive salivation',
        'Fear of water (hydrophobia)',
        'Insomnia',
        'Partial paralysis',
      ],
      prevention: [
        'Vaccinate your pets',
        'Keep your pets under supervision',
        'Don\'t handle wild animals or strays',
        'Contact animal control to report stray animals',
        'Get post-exposure prophylaxis (PEP) immediately if bitten',
      ],
      treatment: [
        'Post-exposure prophylaxis (PEP) including rabies vaccine and rabies immune globulin',
        'Once clinical symptoms appear, there is no effective treatment',
      ],
      severity: 'Critical',
      category: 'Zoonotic Viral Disease',
    ),
    Disease(
      id: 'covid19',
      name: 'COVID-19',
      description: 'Coronavirus disease (COVID-19) is an infectious disease caused by the SARS-CoV-2 virus.',
      symptoms: [
        'Fever',
        'Cough',
        'Tiredness',
        'Loss of taste or smell',
        'Sore throat',
        'Headache',
        'Aches and pains',
        'Diarrhoea',
        'A rash on skin, or discolouration of fingers or toes',
        'Red or irritated eyes',
      ],
      prevention: [
        'Get vaccinated',
        'Wear a mask',
        'Keep a safe distance from others',
        'Clean your hands often',
        'Cough or sneeze into your elbow',
      ],
      treatment: [
        'Self-care (rest, fluids)',
        'Oxygen therapy',
        'Antiviral medications (e.g., Paxlovid, Molnupiravir)',
        'Corticosteroids',
      ],
      severity: 'High to Critical',
      category: 'Respiratory Viral Disease',
    ),
    Disease(
      id: 'dengue',
      name: 'Dengue Fever',
      description: 'Dengue is a viral infection transmitted to humans through the bite of infected mosquitoes.',
      symptoms: [
        'Severe headache',
        'Pain behind the eyes',
        'Muscle and joint pains',
        'Nausea',
        'Vomiting',
        'Swollen glands',
        'Rash',
      ],
      prevention: [
        'Prevent mosquito bites using insect repellent',
        'Wear clothes that cover as much of your body as possible',
        'Use mosquito nets if sleeping during the day',
        'Eliminate mosquito breeding sites (standing water)',
      ],
      treatment: [
        'No specific treatment for dengue',
        'Pain relievers (Acetaminophen/Paracetamol)',
        'Avoid NSAIDs like ibuprofen and aspirin as they can increase bleeding risk',
        'Hydration',
      ],
      severity: 'Moderate to High',
      category: 'Vector-borne Viral Disease',
    ),
    Disease(
      id: 'malaria',
      name: 'Malaria',
      description: 'Malaria is a life-threatening disease spread to humans by some types of mosquitoes.',
      symptoms: [
        'Fever',
        'Chills',
        'Headache',
        'Nausea',
        'Vomiting',
        'Muscle pain',
        'Fatigue',
      ],
      prevention: [
        'Use insecticide-treated mosquito nets',
        'Indoor residual spraying',
        'Preventive medicines (chemoprophylaxis) for travelers',
        'Vaccination (RTS,S/AS01)',
      ],
      treatment: [
        'Artemisinin-based combination therapy (ACT)',
        'Chloroquine (where parasites are sensitive)',
      ],
      severity: 'High',
      category: 'Vector-borne Parasitic Disease',
    ),
    Disease(
      id: 'cholera',
      name: 'Cholera',
      description: 'Cholera is an acute diarrhoeal infection caused by ingestion of food or water contaminated with the bacterium Vibrio cholerae.',
      symptoms: [
        'Profuse watery diarrhoea (rice-water stools)',
        'Vomiting',
        'Rapid heart rate',
        'Loss of skin elasticity',
        'Low blood pressure',
        'Thirst',
        'Muscle cramps',
      ],
      prevention: [
        'Drink and use safe water',
        'Wash your hands often with soap and safe water',
        'Use latrines or bury your feces',
        'Cook food well, keep it covered, and eat it hot',
        'Clean up safely—in the kitchen and in places where the family bathes and washes clothes',
      ],
      treatment: [
        'Oral rehydration solution (ORS)',
        'Intravenous fluids',
        'Antibiotics (for severe cases)',
        'Zinc supplements (for children)',
      ],
      severity: 'High to Critical',
      category: 'Bacterial Disease',
    ),
    Disease(
      id: 'zika',
      name: 'Zika Virus',
      description: 'Zika virus is primarily transmitted by Aedes mosquitoes, which bite during the day.',
      symptoms: [
        'Fever',
        'Rash',
        'Conjunctivitis',
        'Muscle and joint pain',
        'Malaise',
        'Headache',
      ],
      prevention: [
        'Protection against mosquito bites',
        'Eliminating mosquito breeding sites',
        'Safe sexual practices',
      ],
      treatment: [
        'No specific treatment or vaccine',
        'Rest',
        'Fluids',
        'Pain and fever medication',
      ],
      severity: 'Moderate',
      category: 'Vector-borne Viral Disease',
    ),
    Disease(
      id: 'monkeypox',
      name: 'Mpox (Monkeypox)',
      description: 'Mpox is a viral zoonosis (a virus transmitted to humans from animals) with symptoms similar to those seen in smallpox patients.',
      symptoms: [
        'Fever',
        'Headache',
        'Muscle aches',
        'Backache',
        'Swollen lymph nodes',
        'Chills',
        'Exhaustion',
        'A rash that can look like pimples or blisters',
      ],
      prevention: [
        'Avoid contact with animals that could harbor the virus',
        'Avoid contact with any materials that has been in contact with a sick animal',
        'Isolate infected patients',
        'Practice good hand hygiene',
      ],
      treatment: [
        'Supportive care',
        'Antiviral drugs (e.g., Tecovirimat)',
        'Vaccination (Jynneos)',
      ],
      severity: 'Moderate to High',
      category: 'Zoonotic Viral Disease',
    ),
    Disease(
      id: 'measles',
      name: 'Measles',
      description: 'Measles is a highly contagious, serious disease caused by a virus in the paramyxovirus family.',
      symptoms: [
        'High fever',
        'Cough',
        'Runny nose (coryza)',
        'Red, watery eyes (conjunctivitis)',
        'Koplik spots (small white spots inside the cheeks)',
        'Rash starting on face and spreading down',
      ],
      prevention: [
        'MMR vaccination (2 doses)',
        'Isolation of infected individuals',
      ],
      treatment: [
        'No specific antiviral treatment',
        'Supportive care',
        'Vitamin A supplements',
      ],
      severity: 'High',
      category: 'Respiratory Viral Disease',
    ),
    Disease(
      id: 'tuberculosis',
      name: 'Tuberculosis (TB)',
      description: 'TB is caused by bacteria (Mycobacterium tuberculosis) that most often affect the lungs. TB is curable and preventable.',
      symptoms: [
        'Cough that lasts 3 weeks or longer',
        'Chest pain',
        'Coughing up blood',
        'Fatigue',
        'Weight loss',
        'No appetite',
        'Chills',
        'Fever',
        'Sweating at night',
      ],
      prevention: [
        'BCG vaccination',
        'Early diagnosis and treatment',
        'Proper ventilation',
        'Respiratory hygiene',
      ],
      treatment: [
        'Long course of multiple antibiotics (e.g., Isoniazid, Rifampin)',
      ],
      severity: 'High (if untreated)',
      category: 'Bacterial Respiratory Disease',
    ),
    Disease(
      id: 'influenza',
      name: 'Influenza (Flu)',
      description: 'Influenza is an acute viral infection that spreads easily from person to person.',
      symptoms: [
        'Fever',
        'Cough',
        'Headache',
        'Muscle and joint pain',
        'Severe malaise',
        'Sore throat',
        'Runny nose',
      ],
      prevention: [
        'Annual vaccination',
        'Regular hand washing',
        'Avoiding close contact with sick people',
      ],
      treatment: [
        'Rest and fluids',
        'Antiviral drugs (e.g., Oseltamivir) in severe cases',
      ],
      severity: 'Low to Moderate',
      category: 'Respiratory Viral Disease',
    ),
    Disease(
      id: 'common_cold',
      name: 'Common Cold',
      description: 'The common cold is a viral infection of your nose and throat (upper respiratory tract).',
      symptoms: [
        'Runny or stuffy nose',
        'Sore throat',
        'Cough',
        'Congestion',
        'Slight body aches or a mild headache',
        'Sneezing',
        'Low-grade fever',
        'Generally feeling unwell',
      ],
      prevention: [
        'Wash your hands',
        'Disinfect your stuff',
        'Use tissues',
        'Don\'t share',
        'Take care of yourself',
      ],
      treatment: [
        'Rest',
        'Fluids',
        'Over-the-counter cold medicines (for symptom relief)',
      ],
      severity: 'Low',
      category: 'Respiratory Viral Disease',
    ),
    Disease(
      id: 'typhoid',
      name: 'Typhoid Fever',
      description: 'Typhoid fever is a life-threatening infection caused by the bacterium Salmonella Typhi. It is usually spread through contaminated food or water.',
      symptoms: [
        'Prolonged high fever',
        'Fatigue',
        'Headache',
        'Nausea',
        'Abdominal pain',
        'Constipation or diarrhoea',
        'Rash (rose spots)',
      ],
      prevention: [
        'Safe water and food',
        'Typhoid vaccination',
        'Good hand hygiene',
      ],
      treatment: [
        'Antibiotics (e.g., Ciprofloxacin, Azithromycin)',
        'Fluid replacement',
      ],
      severity: 'High',
      category: 'Bacterial Food-borne Disease',
    ),
    Disease(
      id: 'hepatitis_a',
      name: 'Hepatitis A',
      description: 'Hepatitis A is an inflammation of the liver caused by the hepatitis A virus (HAV). The virus is primarily spread when an uninfected person ingests food or water that is contaminated with the faeces of an infected person.',
      symptoms: [
        'Fever',
        'Malaise',
        'Loss of appetite',
        'Diarrhoea',
        'Nausea',
        'Abdominal discomfort',
        'Dark-coloured urine',
        'Jaundice (yellowing of the skin and whites of the eyes)',
      ],
      prevention: [
        'Vaccination',
        'Safe water supply',
        'Proper disposal of sewage',
        'Personal hygiene (hand washing)',
      ],
      treatment: [
        'No specific treatment',
        'Supportive care',
        'Avoid unnecessary medications (to rest the liver)',
      ],
      severity: 'Moderate',
      category: 'Viral Liver Disease',
    ),
    Disease(
      id: 'meningitis',
      name: 'Meningitis',
      description: 'Meningitis is an inflammation of the fluid and membranes (meninges) surrounding your brain and spinal cord.',
      symptoms: [
        'Sudden high fever',
        'Stiff neck',
        'Severe headache',
        'Nausea or vomiting',
        'Confusion or difficulty concentrating',
        'Seizures',
        'Sleepiness or difficulty waking',
        'Sensitivity to light',
        'No appetite or thirst',
        'Skin rash (in some cases)',
      ],
      prevention: [
        'Vaccination',
        'Hand washing',
        'Good hygiene',
        'Boosting immune system',
      ],
      treatment: [
        'Bacterial meningitis requires immediate intravenous antibiotics',
        'Corticosteroids',
        'Supportive care for viral meningitis',
      ],
      severity: 'Critical (Bacterial)',
      category: 'Infectious Neurological Disease',
    ),
    Disease(
      id: 'polio',
      name: 'Poliomyelitis (Polio)',
      description: 'Polio is a highly infectious viral disease that largely affects children under 5 years of age. It can cause total paralysis in a matter of hours.',
      symptoms: [
        'Fever',
        'Fatigue',
        'Headache',
        'Vomiting',
        'Stiffness in the neck',
        'Pain in the limbs',
        'Permanent paralysis (in rare cases)',
      ],
      prevention: [
        'Oral polio vaccine (OPV)',
        'Inactivated polio vaccine (IPV)',
        'Multiple doses for lifetime protection',
      ],
      treatment: [
        'No cure for polio',
        'Supportive care and physical therapy',
      ],
      severity: 'Critical',
      category: 'Enteric Viral Disease',
    ),
    Disease(
      id: 'mumps',
      name: 'Mumps',
      description: 'Mumps is a viral infection that primarily affects the parotid glands—one of three pairs of saliva-producing (salivary) glands.',
      symptoms: [
        'Swollen, painful salivary glands',
        'Fever',
        'Headache',
        'Muscle aches',
        'Weakness and fatigue',
        'Loss of appetite',
        'Pain while chewing or swallowing',
      ],
      prevention: [
        'MMR vaccination',
        'Good hygiene',
      ],
      treatment: [
        'Supportive care',
        'Pain management',
      ],
      severity: 'Moderate',
      category: 'Viral Respiratory Disease',
    ),
    Disease(
      id: 'rubella',
      name: 'Rubella (German Measles)',
      description: 'Rubella is a contagious viral infection best known by its distinctive red rash. It is particularly dangerous for pregnant women.',
      symptoms: [
        'Mild fever',
        'Headache',
        'Stuffy or runny nose',
        'Inflamed, red eyes',
        'Enlarged, tender lymph nodes',
        'A fine, pink rash',
        'Aching joints',
      ],
      prevention: [
        'MMR vaccination',
      ],
      treatment: [
        'Supportive care',
        'Isolation to prevent spread',
      ],
      severity: 'Moderate',
      category: 'Viral Respiratory Disease',
    ),
    Disease(
      id: 'varicella',
      name: 'Varicella (Chickenpox)',
      description: 'Chickenpox is an infection caused by the varicella-zoster virus. It causes an itchy rash with small, fluid-filled blisters.',
      symptoms: [
        'Itchy rash with blisters',
        'Fever',
        'Loss of appetite',
        'Headache',
        'Tiredness and general feeling of being unwell',
      ],
      prevention: [
        'Varicella vaccination',
        'Avoiding contact with infected individuals',
      ],
      treatment: [
        'Symptom relief (anti-itch creams)',
        'Antiviral medication for high-risk individuals',
      ],
      severity: 'Low to Moderate',
      category: 'Viral Skin Disease',
    ),
    Disease(
      id: 'tetanus',
      name: 'Tetanus',
      description: 'Tetanus is a serious disease of the nervous system caused by a toxin-producing bacterium. It causes muscle contractions, particularly of your jaw and neck muscles.',
      symptoms: [
        'Jaw cramping (lockjaw)',
        'Sudden, involuntary muscle spasms',
        'Painful muscle stiffness all over the body',
        'Trouble swallowing',
        'Seizures',
        'Headache',
        'Fever and sweating',
        'Changes in blood pressure and heart rate',
      ],
      prevention: [
        'Tetanus vaccination (Tdap/Td)',
        'Booster doses every 10 years',
        'Proper wound care',
      ],
      treatment: [
        'Immediate medical care',
        'Tetanus immune globulin (TIG)',
        'Antibiotics',
        'Muscle relaxants',
      ],
      severity: 'Critical',
      category: 'Bacterial Neurological Disease',
    ),
  ];

  Future<List<Disease>> searchDiseases(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return _diseases;
    return _diseases.where((d) => d.name.toLowerCase().contains(query.toLowerCase()) || d.category.toLowerCase().contains(query.toLowerCase())).toList();
  }

  Future<Disease?> getDiseaseById(String id) async {
    return _diseases.firstWhere((d) => d.id == id);
  }
}
