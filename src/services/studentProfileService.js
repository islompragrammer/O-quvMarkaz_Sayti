import { studentProfile } from '../mocks/studentProfile.js'

export async function getStudentProfile() {
  return {
    student: { ...studentProfile.student },
    group: {
      ...studentProfile.group,
      lessonDays: [...studentProfile.group.lessonDays],
      attendanceByMonth: Object.fromEntries(
        Object.entries(studentProfile.group.attendanceByMonth).map(([month, attendance]) => [
          month,
          {
            stats: { ...attendance.stats },
            days: attendance.days.map((day) => ({ ...day })),
          },
        ]),
      ),
    },
    payments: studentProfile.payments.map((payment) => ({ ...payment })),
  }
}
