//
//  ContentView.swift
//  UITrace2021-08-17
//
//  Created by 吉田周平 on 2021/08/17.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    var body: some View {
        VStack {
            HStack {
                Button(action: {}, label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                })
                Spacer()
                Button(action: {}, label: {
                    Image(systemName: "bag")
                        .foregroundColor(.black)
                })
            }
            .padding()
            PagingView(index: $viewModel.index.animation(), maxIndex: viewModel.dataCount) {
                ForEach(viewModel.data, id: \.id) { item in
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.blue)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                            HStack {
                                Spacer()
                                VStack(spacing: 40) {
                                    Button(action: {}, label: {
                                        Image(systemName: "star")
                                            .foregroundColor(.black)
                                    })
                                    Button(action: {}, label: {
                                        Image(systemName: "square.and.arrow.up")
                                            .foregroundColor(.black)
                                    })
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        .padding()
                        PageControl(index: $viewModel.index, maxIndex: viewModel.dataCount)
                        Text(item.maker)
                            .fontWeight(.bold)
                            .padding(4)
                        Text(item.description)
                            .padding(4)
                        Text("\(item.fee)")
                            .padding(4)
                    }
                    
                }
            }
            .aspectRatio(3/4, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            HStack {
                Text("Select your size")
                    .foregroundColor(.gray)
                Spacer()
                Divider()
                Spacer()
                    .frame(width: 16)
                Button(action: {}, label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.black)
                })
            }
            .frame(maxWidth: .infinity, maxHeight: 40)
            .padding(.horizontal)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding()
            
            HStack {
                Button(action: {}, label: {
                    Label("Pay", systemImage: "applelogo")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                })
                Button(action: {}, label: {
                    Text("Add to bag")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(4)
                })
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

class ContentViewModel: ObservableObject {
    @Published var index = 0
    
    let data = [
        ItemModel(maker: "Guchi",
                  description: "argyle collaerd vest",
                  fee: 1100),
        ItemModel(maker: "Guchi",
                  description: "argyle collaerd vest",
                  fee: 1100),
        ItemModel(maker: "Guchi",
                  description: "argyle collaerd vest",
                  fee: 1100),
        ItemModel(maker: "Guchi",
                  description: "argyle collaerd vest",
                  fee: 1100),
        ItemModel(maker: "Guchi",
                  description: "argyle collaerd vest",
                  fee: 1100),
        ItemModel(maker: "Guchi",
                  description: "argyle collaerd vest",
                  fee: 1100)
    ]
    
    var dataCount: Int {
        return data.count
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ItemModel {
    var id = UUID()
    var maker: String
    var description: String
    var fee: Int
}

struct PagingView<Content>: View where Content: View {
    
    @Binding var index: Int
    let maxIndex: Int
    let content: () -> Content
    
    @State private var offset = CGFloat.zero
    @State private var dragging = false
    
    init(index: Binding<Int>,
         maxIndex: Int,
         @ViewBuilder content: @escaping () -> Content) {
        self._index = index
        self.maxIndex = maxIndex
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        self.content()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                }
                .content.offset(x: self.offset(in: geometry), y: 0)
                .frame(width: geometry.size.width, alignment: .leading)
                .gesture(
                    DragGesture().onChanged { value in
                        self.dragging = true
                        self.offset = -CGFloat(self.index) * geometry.size.width + value.translation.width
                    }
                    .onEnded { value in
                        let predictedEndOffset = -CGFloat(self.index) * geometry.size.width + value.predictedEndTranslation.width
                        let predictedIndex = Int(round(predictedEndOffset / -geometry.size.width))
                        self.index = self.clampedIndex(from: predictedIndex)
                        withAnimation(.easeOut) {
                            self.dragging = false
                        }
                    }
                )
            }
            .clipped()
        }
    }
    
    func offset(in geometry: GeometryProxy) -> CGFloat {
        if self.dragging {
            return max(min(self.offset, 0), -CGFloat(self.maxIndex) * geometry.size.width)
        } else {
            return -CGFloat(self.index) * geometry.size.width
        }
    }
    
    func clampedIndex(from predictedIndex: Int) -> Int {
        let newIndex = min(max(predictedIndex, self.index - 1), self.index + 1)
        guard newIndex >= 0 else { return 0 }
        guard newIndex <= maxIndex else { return maxIndex }
        return newIndex
    }
}

struct PageControl: View {
    @Binding var index: Int
    let maxIndex: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0...maxIndex, id: \.self) { index in
                Circle()
                    .fill(index == self.index ? Color.blue : Color.gray)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(15)
    }
}
