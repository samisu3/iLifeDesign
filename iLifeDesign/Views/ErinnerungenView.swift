//
//  ErinnerungenView.swift
//  iLifeDesign
//
//  Smart Notifications nach Atomic Habits: keine generischen Erinnerungen,
//  sondern neugierig machende Fragen zur passenden Uhrzeit — plus
//  Habit Stacking (der Ideen-Moment wird an eine eigene Alltagsroutine geknüpft).
//

import SwiftUI
import UserNotifications

// MARK: - Planer für lokale Benachrichtigungen

enum ErinnerungsPlaner {

    static let wochenImpulsID = "erinnerung.wochenimpuls"
    static let abendCheckinID = "erinnerung.abendcheckin"
    static let ideenMomentID  = "erinnerung.ideenmoment"

    /// Fragt die Berechtigung an (falls nötig) und plant alle aktiven Erinnerungen neu.
    static func aktualisiere(
        wochenImpulsAktiv: Bool, wochenImpulsZeit: Double,
        abendCheckinAktiv: Bool, abendCheckinZeit: Double,
        ideenMomentAktiv: Bool, ideenMomentZeit: Double, ideenMomentRoutine: String
    ) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            wochenImpulsID, abendCheckinID, ideenMomentID
        ])

        guard wochenImpulsAktiv || abendCheckinAktiv || ideenMomentAktiv else { return }

        center.requestAuthorization(options: [.alert, .sound, .badge]) { erlaubt, _ in
            guard erlaubt else { return }

            if wochenImpulsAktiv {
                plane(
                    id: wochenImpulsID,
                    titel: "Neue Woche, neue Expedition 🧭",
                    text: "Was willst Du diese Woche testen?",
                    sekundenAbMitternacht: wochenImpulsZeit,
                    wochentag: 1 // Sonntag
                )
            }
            if abendCheckinAktiv {
                plane(
                    id: abendCheckinID,
                    titel: "Kurzer Blick zurück 🌙",
                    text: "Wie lief Dein Experiment heute? Ein Satz genügt.",
                    sekundenAbMitternacht: abendCheckinZeit
                )
            }
            if ideenMomentAktiv {
                let routine = ideenMomentRoutine.trimmingCharacters(in: .whitespacesAndNewlines)
                plane(
                    id: ideenMomentID,
                    titel: "Dein Ideen-Moment ✨",
                    text: routine.isEmpty
                        ? "Was ist Dir aufgefallen? Halte eine Idee fest."
                        : "\(routine): Was ist Dir aufgefallen? Halte eine Idee fest.",
                    sekundenAbMitternacht: ideenMomentZeit
                )
            }
        }
    }

    private static func plane(
        id: String, titel: String, text: String,
        sekundenAbMitternacht: Double, wochentag: Int? = nil
    ) {
        var komponenten = DateComponents()
        komponenten.hour = Int(sekundenAbMitternacht) / 3600
        komponenten.minute = (Int(sekundenAbMitternacht) % 3600) / 60
        if let wochentag { komponenten.weekday = wochentag }

        let inhalt = UNMutableNotificationContent()
        inhalt.title = titel
        inhalt.body = text
        inhalt.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: komponenten, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: inhalt, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Einstellungs-Sheet

struct ErinnerungenView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("wochenImpulsAktiv") private var wochenImpulsAktiv = false
    @AppStorage("wochenImpulsZeit") private var wochenImpulsZeit = 18.0 * 3600
    @AppStorage("abendCheckinAktiv") private var abendCheckinAktiv = false
    @AppStorage("abendCheckinZeit") private var abendCheckinZeit = 20.5 * 3600
    @AppStorage("ideenMomentAktiv") private var ideenMomentAktiv = false
    @AppStorage("ideenMomentZeit") private var ideenMomentZeit = 7.5 * 3600
    @AppStorage("ideenMomentRoutine") private var ideenMomentRoutine = "Beim Morgenkaffee"

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Wochen-Impuls
                Section {
                    Toggle(isOn: $wochenImpulsAktiv) {
                        Label("Sonntags-Impuls", systemImage: "safari")
                    }
                    if wochenImpulsAktiv {
                        DatePicker(
                            "Uhrzeit",
                            selection: zeitBinding($wochenImpulsZeit),
                            displayedComponents: .hourAndMinute
                        )
                    }
                } footer: {
                    Text("„Was willst Du diese Woche testen?“ — jeden Sonntag als Startschuss für den nächsten Loop.")
                }

                // MARK: Abend-Check-in
                Section {
                    Toggle(isOn: $abendCheckinAktiv) {
                        Label("Abend-Check-in", systemImage: "moon.stars")
                    }
                    if abendCheckinAktiv {
                        DatePicker(
                            "Uhrzeit",
                            selection: zeitBinding($abendCheckinZeit),
                            displayedComponents: .hourAndMinute
                        )
                    }
                } footer: {
                    Text("„Wie lief Dein Experiment heute?“ — täglich am Abend, ein Satz genügt.")
                }

                // MARK: Ideen-Moment (Habit Stacking)
                Section {
                    Toggle(isOn: $ideenMomentAktiv) {
                        Label("Ideen-Moment", systemImage: "sparkles")
                    }
                    if ideenMomentAktiv {
                        TextField("Deine Routine (z. B. Beim Morgenkaffee)", text: $ideenMomentRoutine)
                        DatePicker(
                            "Uhrzeit",
                            selection: zeitBinding($ideenMomentZeit),
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("Habit Stacking")
                } footer: {
                    Text("Knüpfe das Ideen-Festhalten an eine bestehende Routine: Wann denkst Du meistens über neue Ideen nach?")
                }
            }
            .navigationTitle("Erinnerungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
            .onDisappear { planeNeu() }
            .onChange(of: wochenImpulsAktiv) { planeNeu() }
            .onChange(of: abendCheckinAktiv) { planeNeu() }
            .onChange(of: ideenMomentAktiv) { planeNeu() }
            .onChange(of: wochenImpulsZeit) { planeNeu() }
            .onChange(of: abendCheckinZeit) { planeNeu() }
            .onChange(of: ideenMomentZeit) { planeNeu() }
        }
    }

    private func planeNeu() {
        ErinnerungsPlaner.aktualisiere(
            wochenImpulsAktiv: wochenImpulsAktiv, wochenImpulsZeit: wochenImpulsZeit,
            abendCheckinAktiv: abendCheckinAktiv, abendCheckinZeit: abendCheckinZeit,
            ideenMomentAktiv: ideenMomentAktiv, ideenMomentZeit: ideenMomentZeit,
            ideenMomentRoutine: ideenMomentRoutine
        )
    }

    /// Wandelt die gespeicherten Sekunden-ab-Mitternacht in ein Date für den DatePicker um.
    private func zeitBinding(_ speicher: Binding<Double>) -> Binding<Date> {
        Binding<Date>(
            get: {
                Calendar.current.startOfDay(for: .now)
                    .addingTimeInterval(speicher.wrappedValue)
            },
            set: { neuesDatum in
                let komponenten = Calendar.current.dateComponents([.hour, .minute], from: neuesDatum)
                speicher.wrappedValue = Double((komponenten.hour ?? 0) * 3600 + (komponenten.minute ?? 0) * 60)
            }
        )
    }
}

// MARK: - Preview

#Preview {
    ErinnerungenView()
}
