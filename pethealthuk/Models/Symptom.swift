//
//  Symptom.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import Foundation

enum SymptomSeverity: String, CaseIterable, Codable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    case emergency = "Emergency"

    var color: String {
        switch self {
        case .mild: return "green"
        case .moderate: return "yellow"
        case .severe: return "orange"
        case .emergency: return "red"
        }
    }
}

struct SymptomCategory: Identifiable {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var symptoms: [Symptom]
}

struct Symptom: Identifiable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var possibleCauses: [String]
    var homeAdvice: String
    var severity: SymptomSeverity
    var seekVetIf: [String]
    var applicableSpecies: [PetSpecies]
}

extension SymptomCategory {
    static let categories: [SymptomCategory] = [
        SymptomCategory(
            name: "Digestive",
            icon: "stomach",
            symptoms: [
                Symptom(
                    name: "Vomiting",
                    description: "Your pet is throwing up food, liquid, or bile",
                    possibleCauses: ["Eating too fast", "Dietary changes", "Infection", "Poisoning", "Blockage"],
                    homeAdvice: "Withhold food for 12-24 hours, provide small amounts of water. Introduce bland diet gradually.",
                    severity: .moderate,
                    seekVetIf: ["Vomiting persists more than 24 hours", "Blood in vomit", "Lethargy or weakness", "Suspected poisoning"],
                    applicableSpecies: [.dog, .cat, .rabbit, .guineaPig]
                ),
                Symptom(
                    name: "Diarrhoea",
                    description: "Loose or watery stools",
                    possibleCauses: ["Dietary changes", "Stress", "Parasites", "Infection", "Food intolerance"],
                    homeAdvice: "Ensure hydration, feed bland diet (boiled chicken and rice for dogs/cats). Monitor closely.",
                    severity: .moderate,
                    seekVetIf: ["Blood in stool", "Lasts more than 48 hours", "Accompanied by vomiting", "Signs of dehydration"],
                    applicableSpecies: [.dog, .cat, .rabbit, .guineaPig, .hamster]
                ),
                Symptom(
                    name: "Loss of Appetite",
                    description: "Reduced interest in food or refusing to eat",
                    possibleCauses: ["Illness", "Dental problems", "Stress", "Food preferences", "Pain"],
                    homeAdvice: "Try warming food slightly, offer favourite treats. Ensure fresh water is available.",
                    severity: .mild,
                    seekVetIf: ["No eating for 24+ hours (cats) or 48+ hours (dogs)", "Accompanied by other symptoms", "Weight loss"],
                    applicableSpecies: PetSpecies.allCases
                )
            ]
        ),
        SymptomCategory(
            name: "Respiratory",
            icon: "lungs.fill",
            symptoms: [
                Symptom(
                    name: "Coughing",
                    description: "Repeated coughing or hacking sounds",
                    possibleCauses: ["Kennel cough", "Allergies", "Heart disease", "Respiratory infection", "Foreign object"],
                    homeAdvice: "Keep pet calm and in well-ventilated area. Avoid irritants like smoke.",
                    severity: .moderate,
                    seekVetIf: ["Coughing persists more than a few days", "Difficulty breathing", "Blue gums", "Coughing up blood"],
                    applicableSpecies: [.dog, .cat]
                ),
                Symptom(
                    name: "Difficulty Breathing",
                    description: "Laboured breathing, gasping, or unusual breathing sounds",
                    possibleCauses: ["Respiratory infection", "Heart problems", "Allergic reaction", "Obstruction", "Heat stroke"],
                    homeAdvice: "Keep pet cool and calm. This requires immediate veterinary attention.",
                    severity: .emergency,
                    seekVetIf: ["Any difficulty breathing should be seen immediately"],
                    applicableSpecies: PetSpecies.allCases
                )
            ]
        ),
        SymptomCategory(
            name: "Skin & Coat",
            icon: "allergens",
            symptoms: [
                Symptom(
                    name: "Itching/Scratching",
                    description: "Excessive scratching, licking, or biting at skin",
                    possibleCauses: ["Fleas", "Allergies", "Dry skin", "Mites", "Infection"],
                    homeAdvice: "Check for fleas, ensure flea treatment is up to date. Oatmeal baths can soothe irritation.",
                    severity: .mild,
                    seekVetIf: ["Broken skin or sores", "Hair loss", "Spreading rash", "No improvement with flea treatment"],
                    applicableSpecies: [.dog, .cat, .rabbit, .guineaPig, .hamster]
                ),
                Symptom(
                    name: "Hair Loss",
                    description: "Patches of missing fur or thinning coat",
                    possibleCauses: ["Allergies", "Parasites", "Hormonal imbalance", "Stress", "Fungal infection"],
                    homeAdvice: "Document the areas affected. Avoid over-bathing.",
                    severity: .moderate,
                    seekVetIf: ["Spreading patches", "Red or irritated skin", "Accompanied by itching", "Symmetrical hair loss"],
                    applicableSpecies: [.dog, .cat, .rabbit, .guineaPig, .hamster]
                )
            ]
        ),
        SymptomCategory(
            name: "Mobility",
            icon: "figure.walk",
            symptoms: [
                Symptom(
                    name: "Limping",
                    description: "Favouring one leg or reluctance to put weight on a limb",
                    possibleCauses: ["Injury", "Arthritis", "Sprain", "Broken bone", "Joint problems"],
                    homeAdvice: "Rest the pet, limit exercise. Check paw for foreign objects.",
                    severity: .moderate,
                    seekVetIf: ["Severe pain", "Swelling", "Unable to bear weight", "Limp persists more than 24-48 hours"],
                    applicableSpecies: [.dog, .cat, .rabbit]
                ),
                Symptom(
                    name: "Difficulty Standing",
                    description: "Struggling to get up or stand",
                    possibleCauses: ["Arthritis", "Injury", "Neurological issues", "Weakness", "Pain"],
                    homeAdvice: "Keep pet comfortable on soft bedding. Assist gently when needed.",
                    severity: .severe,
                    seekVetIf: ["Sudden onset", "Accompanied by pain", "Inability to stand at all", "Loss of coordination"],
                    applicableSpecies: [.dog, .cat]
                )
            ]
        ),
        SymptomCategory(
            name: "Behaviour",
            icon: "brain.head.profile",
            symptoms: [
                Symptom(
                    name: "Lethargy",
                    description: "Unusual tiredness or lack of energy",
                    possibleCauses: ["Illness", "Pain", "Infection", "Anaemia", "Depression"],
                    homeAdvice: "Monitor closely, ensure comfortable resting area. Note any other symptoms.",
                    severity: .moderate,
                    seekVetIf: ["Persists more than 24 hours", "Accompanied by other symptoms", "Sudden onset", "Not eating or drinking"],
                    applicableSpecies: PetSpecies.allCases
                ),
                Symptom(
                    name: "Aggression Changes",
                    description: "Unusual aggression or irritability",
                    possibleCauses: ["Pain", "Fear", "Illness", "Hormonal changes", "Neurological issues"],
                    homeAdvice: "Give pet space, avoid triggers. Do not punish - this may indicate pain.",
                    severity: .moderate,
                    seekVetIf: ["Sudden personality change", "Accompanied by other symptoms", "Risk of harm"],
                    applicableSpecies: [.dog, .cat]
                )
            ]
        ),
        SymptomCategory(
            name: "Eyes & Ears",
            icon: "eye.fill",
            symptoms: [
                Symptom(
                    name: "Eye Discharge",
                    description: "Unusual discharge, redness, or swelling around eyes",
                    possibleCauses: ["Infection", "Allergies", "Injury", "Blocked tear duct", "Conjunctivitis"],
                    homeAdvice: "Gently clean with warm water and cotton wool. Do not use human eye drops.",
                    severity: .moderate,
                    seekVetIf: ["Yellow or green discharge", "Eye appears painful", "Swelling", "Vision seems affected"],
                    applicableSpecies: [.dog, .cat, .rabbit, .guineaPig]
                ),
                Symptom(
                    name: "Ear Problems",
                    description: "Head shaking, scratching ears, discharge, or odour",
                    possibleCauses: ["Ear infection", "Mites", "Allergies", "Foreign object", "Yeast"],
                    homeAdvice: "Do not insert anything into ear canal. Keep ears dry.",
                    severity: .moderate,
                    seekVetIf: ["Discharge or odour", "Persistent head shaking", "Pain when touched", "Loss of balance"],
                    applicableSpecies: [.dog, .cat, .rabbit]
                )
            ]
        )
    ]
}
