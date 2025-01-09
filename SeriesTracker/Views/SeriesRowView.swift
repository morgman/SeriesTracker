//
//  SeriesRowView.swift
//  SeriesTracker
//
//  Created by Michael O'Connor on 12/21/24.
//

import SwiftUI

struct SeriesRowView: View {
    var series: Series
    
    var body: some View {
        HStack {
            
            VStack(alignment: .leading) {
                HStack{
                    Text(series.name)
                    Text("[\(series.books.count) books]")
                }
                HStack {
                    Text(series.lastReadBookName() ?? "Unread")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(series.lastReadBook() ?? Date(), style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Image(systemName: series.seriesStatus.statusIcon())
                .foregroundColor(series.seriesStatus.statusColor())
        }
    }
}

#Preview {
    let series = Series.randomSeries()
    SeriesRowView(series: series)
        .padding(.horizontal)
}

